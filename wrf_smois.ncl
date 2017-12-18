
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  a = addfile("/glade/scratch/acaruth/HurricaneErin/modernday/wrfout_d02_all.nc","r")

; We generate plots, but what kind do we prefer?
;  type = "x11"
;  type = "pdf"
;  type = "ps"
   type = "png"
  wks = gsn_open_wks(type,"plt_smois_test")
  gsn_define_colormap(wks,"MPL_Greens")

; Set some basic resources
  res = True
  res@MainTitle                   = "REAL-TIME WRF"

  pltres = True
  mpres = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  times = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  do it = 0, 1 ,1             ; TIME LOOP

    print("Working on time: " + times(it) )
    res@iTimeLabel = times(it)   ; Set Valid time to use on plots


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need        
	
 smois = wrf_user_getvar(a, "SMOIS", it) 

 ;print(smois(1,:,1,1))
 ;print(dimsizes(smois))
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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


res@TimeLabel = "00Z 18 August 2007"   ; Set Valid time to use on plots



    ; Plotting options for T                
      opts = res 
      opts@cnFillOn = True                          
      opts@FieldTitle = "Soil Moisture at 10cm "
      ;opts@gsnSpreadColorEnd = -3  ; End third from the last color in color map
      contour_smois = wrf_contour(a,wks,smois(0,:,:),opts)
      delete(opts)


    ; Plotting options for Td
    ;  opts = res         
    ;;  opts@cnFillOn = True 
    ;  opts@cnLinesOn = True
    ;  opts@cnLineLabelsOn = True
    ;  opts@ContourParameters = (/ -20., 90., 5./) 
    ;  opts@cnLineLabelBackgroundColor = -1
    ;  opts@gsnSpreadColorEnd = -3  ; End third from the last color in color map
    ;  contour_td = wrf_contour(a,wks,td_f,opts)
    ;  delete(opts)



    ; MAKE PLOTS                         
      plot = wrf_map_overlays(a,wks,(/contour_smois/),pltres,mpres)
      ;plot = wrf_map_overlays(a,wks,(/contour_td,vector/),pltres,mpres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  end do        ; END OF TIME LOOP

end
