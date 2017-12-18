
;Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This script will find the max wind in a tropical Cyclone
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ; The WRF ARW input file.
; This needs to have a ".nc" appended, so just do it.

  apre = addfile("/glade/scratch/acaruth/HurricaneErin/presettle/wrfout_d02_all.nc","r")

;  adust = addfile("/glade/scratch/acaruth/HurricaneErin/dust1930s/wrfout_d02_all.nc","r")

  amodern = addfile("/glade/scratch/acaruth/HurricaneErin/modernday/wrfout_d02_all.nc","r")

; a1920s = addfile("/glade/scratch/acaruth/HurricaneErin/1920s/wrfout_d02_all.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; What times and how many time steps are in the data set?
  times = wrf_user_getvar(amodern,"times", -1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get them vars
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MODERN

 u10_modern = wrf_user_getvar(amodern,"U10",-1)    ; u at 10 m, mass point
 v10_modern = wrf_user_getvar(amodern,"V10",-1)    ; v at 10 m, mass point

;get the maxes 

; create the entire wind 
wind_modern = sqrt((u10_modern(0:16,:,:))^2 + (v10_modern(0:16,:,:))^2); only from 00Z 18 - 00Z 20

print("done with modern")

wind_max_modern = dim_max_n(wind_modern,0)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PRE

 u10_pre = wrf_user_getvar(apre,"U10",-1)    ; u at 10 m, mass point
 v10_pre = wrf_user_getvar(apre,"V10",-1)    ; v at 10 m, mass point

;get the maxes

; create the entire wind

wind_pre = sqrt((u10_pre(0:16,:,:))^2 + (v10_pre(0:16,:,:))^2) ; only from 00Z 18 - 00Z 16

print("done with pre")

wind_max_pre = dim_max_n(wind_pre,0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Make some differences 

; modern - pre

diffr = wind_max_modern - wind_max_pre 

print("made the difference")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; We generate plots, but what kind do we prefer?
;  type = "x11"
;  type = "pdf"
  type = "png"
; type = "ncgm"
  wks = gsn_open_wks(type,"maxwind_diffr_pre")
; gsn_define_colormap(wks,"BlueWhiteOrangeRed")
  gsn_define_colormap(wks,"NCV_blue_red")


 mpGridAndLimbOn= True

; Set some basic resources
  res = True
  res@MainTitle                   = "Present Day minus Pre-settlement Land Use:"

  pltres = True
  mpres = True

mpGridAndLimbOn= True



mpres@mpGeophysicalLineColor = "Black"
  mpres@mpNationalLineColor    = "Black"
  mpres@mpUSStateLineColor     = "Black"
   mpres@mpGridLineColor        = "transparent"
   mpres@mpLimbLineColor        = "transparent"
   mpres@mpPerimLineColor       = "transparent"
  mpres@mpGeophysicalLineThicknessF = 2
  mpres@mpUSStateLineThicknessF = 2
  mpres@mpNationalLineThicknessF    = 2





res@TimeLabel = "00Z 18 Aug - 00Z 20 Aug"   ; Set Valid time to use on plots

 ; Plotting options for max wind
        opts = res
        opts@cnFillOn = True
        opts@FieldTitle = "Maximum Wind Speed (m/s)"

 opts@gsnSpreadColorEnd = -3  ; End third from the last color in color map
        ;opts@cnLinesOn = True
        ;opts@cnLineColor = "Blue"
        ;opts@cnLineLabelBackgroundColor = -1
        opts@ContourParameters = (/-8, 8, 1/)
        ;opts@gsnContourLineThicknessesScale = 2.0
        contour_maxwind = wrf_contour(amodern,wks,diffr,opts)
        delete(opts)

; MAKE PLOTS
      plot = wrf_map_overlays(amodern,wks,(/contour_maxwind/),pltres,  mpres)





