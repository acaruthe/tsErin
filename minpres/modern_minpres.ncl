
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

;  apre = addfile("/glade/scratch/acaruth/HurricaneErin/presettle/wrfout_d02_all.nc","r")

;  adust = addfile("/glade/scratch/acaruth/HurricaneErin/dust1930s/wrfout_d02_all.nc","r")

  amodern = addfile("/glade/scratch/acaruth/HurricaneErin/modernday/wrfout_d02_all.nc","r")

; a1920s = addfile("/glade/scratch/acaruth/HurricaneErin/1920s/wrfout_d02_all.nc","r")




; We generate plots, but what kind do we prefer?
;  type = "x11"
;  type = "pdf"
  type = "png"
; type = "ncgm"
  wks = gsn_open_wks(type,"../minpres_modern") ;name me please

gsn_define_colormap(wks,"BlueDarkRed18") ;color table

; Set some basic resources
  res = True
  res@MainTitle                   = "Present Day Land Use"

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  times = wrf_user_getvar(amodern,"times", -1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get them vars 


;do it = 0,ntimes, 1

;  print("Working on time: " + times(it) )
;  res@TimeLabel = times(it)   ; Set Valid time to use on plots


 pres = wrf_user_getvar(amodern,"slp",-1)    ; v at 10 m, mass point
 wrf_smooth_2d(pres, 27) 


 pres2min = wrf_user_getvar(amodern, "slp", -1) 


;;;
;get the min 

pres_min = dim_min_n(pres2min(0:16,:,:),0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; We generate plots, but what kind do we prefer?
;  type = "x11"
;  type = "pdf"
  type = "png"
  
; gsn_define_colormap(wks,"BlueWhiteOrangeRed")
; gsn_define_colormap(wks,"NCV_blue_red")
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


res@TimeLabel = "00Z 19 August 2007"   ; Set Valid time to use on plots

 ; Plotting options for max wind
        opts = res
        opts@cnFillOn = True
        opts@FieldTitle = "Minimum pressure (hPa) 00Z 18 Aug - 00Z 20 Aug"

 opts@gsnSpreadColorEnd = -3  ; End third from the last color in color map
        ;opts@cnLinesOn = True
        ;opts@cnLineColor = "Blue"
        ;opts@cnLineLabelBackgroundColor = -1
        ;opts@ContourParameters = (/0, 20, 1/)
        ;opts@gsnContourLineThicknessesScale = 2.0
        contour_minpres = wrf_contour(amodern,wks,pres_min,opts)
        delete(opts)


; Plotting options for SLP
      opts = res
      opts@cnLineColor = "Black"
      opts@ContourParameters = (/ 996., 1020., 2. /)
      opts@cnLineLabelBackgroundColor = -1
      opts@gsnContourLineThicknessesScale = 4.0
      contour_psl = wrf_contour(amodern,wks,pres(8,:,:),opts)
      delete(opts)




; MAKE PLOTS
      plot = wrf_map_overlays(amodern,wks,(/contour_minpres, contour_psl/),pltres,  mpres)













