#!/usr/bin/Rscript
library(ncdf4)
library(raster)
rm(list = ls())

args = commandArgs(trailingOnly=TRUE)
nd = args[1]

lf1 = strsplit(nd, split = "/")[[1]]
data_in = paste(lf1[1:(length(lf1)-1)], collapse = "/")
lf = lf1[length(lf1)]

nc = nc_open(paste0(data_in, "/", lf))
rnc = stack(paste0(data_in, "/", lf))

lon = ncvar_get(nc, "lon");
lon = lon[lon >= 90 & lon <= 150];
lat = ncvar_get(nc, "lat")
lat = lat[lat >= -15 & lat <= 15]

e = raster()
extent(e) = c(xmn = 90, xmx = 150, ymn = -15, ymx = 15)
rnc_crop = crop(rnc[[2]], e)
mrnc_crop = as.matrix(rnc_crop)

putar90cwise = function(x){
  hasil = t(apply(x, 2, FUN = rev))
  return(hasil)
}
mrnc_crop = putar90cwise(x = mrnc_crop)

ymdh = strsplit(lf, split = "_")[[1]][2]
YY = substr(ymdh, 1, 4)
MM = substr(ymdh, 5, 6)
DD = substr(ymdh, 7, 8)
HH = as.integer(substr(ymdh, 9, 10))
YYYYMMDD = paste0(YY, "-", MM, "-", DD)
waktu_nc_gmt <- sprintf("hours since %s %d",YYYYMMDD,HH) 

# <<<<<<<<<<<<<<< persiapan regrid >>>>>>>>>>>>>>>>>>>>> #
m <- as.integer(args[2]) ; n <- as.integer(args[3]) # m = bujur km dan n = lintang km
if( m < 4 ){      
  if( n < 4 ){
    n <- 4; m <- 4
  }
}
skiplon <- as.integer(m/4);
skiplat <- as.integer(n/4)

source("specialized_regrid.R")
source("specialized_ncout.R")
hasil = specialized_regrid(data = mrnc_crop,
                          bujur = lon,lintang = lat,
                          skip_bujur = skiplon, skip_lintang = skiplat)
print(paste0("coarsing data ... ", lf, " sebesar ", m, " x ", n, " km"))
specialized_ncout(waktu = waktu_nc_gmt, nama_var = hasil, nama_output = paste0("merg_", ymdh, "_4km-pixel.nc4"), 
                  lon = as.numeric(rownames(hasil)), 
                  lat = as.numeric(colnames(hasil)) 
                  )




