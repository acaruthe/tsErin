
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  a = addfile("/glade/scratch/acaruth/HurricaneErin/presettle/wrfout_d02_all.nc","r")
  amodern = addfile("/glade/scratch/acaruth/HurricaneErin/modernday/wrfout_d02_all.nc","r")


; We generate plots, but what kind do we prefer?
;  type = "x11"
;  type = "pdf"
; type = "ps"
 type = "png"
  wks = gsn_open_wks(type,"precip_pre_diffr")
  gsn_define_colormap(wks,"NCV_blue_red")

; Set some basic resources
  res = True
  res@MainTitle = "Present Day minus Pre-settlement Land Use"

  pltres = True
  mpres = True
  mpres@mpGeophysicalLineColor = "Black"
  mpres@mpNationalLineColor    = "Black"
  mpres@mpUSStateLineColor     = "Black"
  mpres@mpGridLineColor        = "Black"
  mpres@mpLimbLineColor        = "Black"
  mpres@mpPerimLineColor       = "Black"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  FirstTime = True
  times = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; pre


  do it = 0, 16, 16             ; TIME LOOP

    print("Working on time: " + times(it) )
    if (FirstTime) then            ; Save some times for tracking tendencies
      times_sav = times(it)
    end if
    res@TimeLabel = times(it)   ; Set Valid time to use on plots

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need        


  ; Get non-convective, convective and total precipitation
  ; Calculate tendency values                               
    rain_exp = wrf_user_getvar(a,"RAINNC",it)
    rain_con = wrf_user_getvar(a,"RAINC",it)
    rain_tot = rain_exp + rain_con
    rain_tot@description = "Total Precipitation"

    if( FirstTime ) then
      if ( it .eq. 0 ) then
        rain_exp_save = rain_exp
        rain_con_save = rain_con
        rain_tot_save = rain_tot
      else
        rain_exp_save = wrf_user_getvar(a,"RAINNC",it-1)
        rain_con_save = wrf_user_getvar(a,"RAINC",it-1)
        rain_tot_save = rain_exp_save + rain_con_save
        FirstTime = False
        times_sav = times(it-1)
      end if
    end if

    rain_exp_tend = rain_exp - rain_exp_save
    rain_con_tend = rain_con - rain_con_save
    rain_tot_tend = rain_tot - rain_tot_save
    rain_exp_tend@description = "Explicit Precipitation Tendency"
    rain_con_tend@description = "Param  Precipitation Tendency"
    rain_tot_tend@description = "Precipitation Tendency"

  ; Bookkeeping, just to allow the tendency at the next time step
    rain_exp_save = rain_exp
    rain_con_save = rain_con
    rain_tot_save = rain_tot

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; modernday 
 ; First get the variables we will need


  ; Get non-convective, convective and total precipitation
  ; Calculate tendency values
    rain_exp_modern = wrf_user_getvar(amodern,"RAINNC",it)
    rain_con_modern = wrf_user_getvar(amodern,"RAINC",it)
    rain_tot_modern = rain_exp_modern + rain_con_modern
    rain_tot_modern@description = "Total Precipitation"

    if( FirstTime ) then
      if ( it .eq. 0 ) then
        rain_exp_save_modern = rain_exp_modern
        rain_con_save_modern = rain_con_modern
        rain_tot_save_modern = rain_tot_modern
      else
        rain_exp_save_modern = wrf_user_getvar(amodern,"RAINNC",it-1)
        rain_con_save_modern = wrf_user_getvar(amodern,"RAINC",it-1)
        rain_tot_save_modern = rain_exp_save_modern + rain_con_save_modern
        FirstTime = False
        times_sav = times(it-1)
      end if
    end if

    rain_exp_tend_modern = rain_exp_modern- rain_exp_save_modern
    rain_con_tend_modern = rain_con_modern - rain_con_save_modern
    rain_tot_tend_modern = rain_tot_modern - rain_tot_save_modern
    rain_exp_tend_modern@description = "Explicit Precipitation Tendency"
    rain_con_tend_modern@description = "Param  Precipitation Tendency"
    rain_tot_tend_modern@description = "Precipitation Tendency"

  ; Bookkeeping, just to allow the tendency at the next time step
    rain_exp_save_modern = rain_exp_modern
    rain_con_save_modern = rain_con_modern
    rain_tot_save_modern = rain_tot_modern


 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;difference

diffr = rain_tot_modern - rain_tot
diffr@description = "Accumulated precipitaiton difference (mm)"

    if( .not. FirstTime ) then     ; We will skip the first time
   
     res@TimeLabel = "00Z 18 Aug - 00Z 20 Aug 2007"   
    
      ; Plotting options for Precipitation
        opts_r = res 
	opts_r@cnFillOn = True
	opts_r@cnFieldTitle = "Accumulated Precipitation Difference (mm)"       
	opts_r@gsnSpreadColorEnd = -3
	opts_r@ContourParameters = (/-200,200,25/)
 	contour_tot = wrf_contour(a,wks, diffr, opts_r)
    	delete(opts_r)

        
       ; plotting for total rain 
	opts_r  = res
	opts_r@UnitLabel = "mm"
	opts_r@cnLinesOn = True
	opts_r@cnLineColor = "Black"
	opts_r@gsnContourLineThicknessesScale = 2.0
	 opts_r@UnitLabel            = "mm"
        opts_r@cnLevelSelectionMode = "ExplicitLevels"
        opts_r@cnLevels             = (/0., 200./)
       
 	contour_tot_now = wrf_contour(a,wks,rain_tot, opts_r)
	delete(opts_r)    

      ; Precipitation Tendencies 
      ;  opts_r@SubFieldTitle = "from " + times_sav + " to " + times(it)
    
        ;contour_tend = wrf_contour(a,wks, rain_tot_tend,opts_r) ; total (color)
        ;contour_res = wrf_contour(a,wks,rain_exp_tend,opts_r)   ; exp (color)
       ; opts_r@cnFillOn = False
       ; opts_r@cnLineColor = "Red4"
       ; contour_prm = wrf_contour(a,wks,rain_con_tend,opts_r)   ; con (red lines)
       ; delete(opts_r)



      ; MAKE PLOTS                                       

        ; Total Precipitation 
          plot = wrf_map_overlays(a,wks,(/contour_tot, contour_tot_now/),pltres,mpres)



    end if    ; END IF FOR SKIPPING FIRST TIME

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    times_sav = times(it)
    FirstTime = False
  end do        ; END OF TIME LOOP

end
