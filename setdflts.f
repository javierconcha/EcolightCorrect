C     Last change:  LKS   8 Nov 2008    9:36 am
      subroutine SETDFLTS
c
c     user routine on file setdflts.f
c
c     called by routine INITIAL [MAIN->INITIAL->SETDFLTS]
c
c     This routine sets various defaults for Ecolight.  Users can
c     change these values to modify the running of Ecolight.
c
      INCLUDE "DIMENS_XL.INC"
c
      Character sl*2, bsl*2, sysl*1
      Character*120 dirEco
C
      COMMON /Cdirnames/ datadir,digitdir,spreadir,
     1                   phasedir,surfdir,bottdir, Pdir
      Character*120 datadir, digitdir, spreadir, 
     1              phasedir, surfdir,bottdir, Pdir

      Character surfname*120,pfname*120,
     1           Drootname*120,Srootname*120,Mrootname*120,
     2           datafiles*120
      COMMON /Cfilenames/ surfname,pfname(mxcomp),
     1                    Drootname,Srootname,Mrootname,
     2                    datafiles(0:7+mxcomp)

      COMMON /Csky/ iskyflag,skyspecs(mxnsky)
      COMMON /Cmisc/ imisc(30),fmisc(30)
c
c     common block for communication with the Gregg & Carder sky
c     irradiance model (routine GCEd)
      common /cgcirr1/ iein,iblw,jday,rlon,rlat,the,hr,pres,am,rh,
     1                 wv,wsm,ws,vi,ro3
c
c     **Common block shared only with subroutine lidata (in gcirrad.f)
c     **(& listed in main.f)
c     **Contains the filename written
c     **in a format agreeable with the system (UNIX/PC)
      COMMON/gcifname/gcifile
      character*120 gcifile
c
      logical IamEL
      external IamEL  
      character*10 whatIam(0:1)
      data whatIam/"Hydrolight", "Ecolight"/      !sets paths
      integer iam
c
c-----  SET PROGRAM TYPE  ---------------------
      if(IamEL()) then
        iam=1
      else
        iam=0
      endif
c-----  SET DIRECTORIES FOR THE USER'S COMPUTER  ---------------------
c
c     Set the directory names where the input data (e.g. surface-
c     information, discretized phase functions, or user-supplied data
c     files) and archived output (the files of printout, digital data,
c     and spreadsheet data)are found.  These specifications have slightly 
c     different forms for UNIX and DOS machines (e.g., the use of "\"
c     in DOS versus "/" in UNIX).
c
c     The default is to assume that Hydrolight is being run from the 
c     directory containing the main code, e.g. from
c
c     c:\HE5\maincode        on a DOS machine, or from
c
c     /usr/HE5/maincode      on a UNIX machine.
c
c     Therefore, the other directories are given as relative paths
c     starting from this directory:
C
C     ***  SPECIFY YOUR SYSTEM HERE:  Microsoft Windows (DOS style) or UNIX
c
c     For DOS machines: use backslash
cJC      sl='\ '
cCJ      sysl=sl(1:1)
c     For UNIX machines: use slash
      bsl='/ '
      sysl=bsl(1:1)

cJC     root directory
         dirEco(1:32)= sysl //'home'// sysl //'jxc4005'// sysl
     1              // 'ecolight52_install'

C'
c
c        The directory containing the input data files:
cJC         datadir = '..' // sysl // 'data' // sysl
         datadir = dirEco(1:32) // sysl // 'data' // sysl
c  
c        The directory where digital output is to be archived:
cJC         digitdir = '..' // sysl // 'output' // sysl //
cJC     1              trim(whatIam(iam)) // sysl // 
cJC     2              'digital' // sysl

         digitdir ='./'
c
c        The directory where spreadsheet output is to be archived:
cJC         spreadir = '..' // sysl // 'output'  // sysl // 
cJC     1              trim(whatIam(iam)) // sysl // 
cJC     2              'excel' // sysl
         spreadir = './'

c
c        The directory containing discretized windsurface files:
cJC         phasedir = '..' // sysl // 'data' // sysl // 'phasefun' // sysl
cJC     1              // trim(whatIam(iam)) // sysl
         phasedir = dirEco(1:32) // sysl // 'data' // sysl //
     1        'phasefun' // sysl  // trim(whatIam(iam)) // sysl

c
c        The directory containing discretized phase function files:
cJC         surfdir = '..' // sysl // 'data' // sysl // 'surfaces' // sysl
CJC     1              // trim(whatIam(iam)) // sysl
         surfdir = dirEco(1:32) // sysl // 'data' // sysl // 
     1         'surfaces' // sysl // trim(whatIam(iam)) // sysl

c
c        The directory containing bottom reflectance files:
cJC         bottdir = '..' // sysl // 'data' // sysl // 'botmrefl' // sysl
         bottdir = dirEco(1:32) // sysl // 'data' // sysl //
     1         'botmrefl' // sysl
c
c        The directory where Printout ASCII output is to be archived:
cJC         Pdir = '..' // sysl // 'output' // sysl //
cJC     1          trim(whatIam(iam)) // sysl // 
cJC     1          'Printout' // sysl
         Pdir = './'
c
c-----  ATMOSPHERIC CONDITIONS FOR G&C SKY IRRADIANCE MODEL  -------
c
c     Set various quantities to define the atmospheric conditions
c     for the Gregg and Carder "skyirrad" model on file "gcirrad.f"
c     These defaults can be changed to tailor the Gregg and
c     Carder model to specific locations, times, and meteorological
c     conditions.  See file gcirrad.f for full documentation.
c     NOTE:  these values are used only if the gcirrad routine is
c     the one named in the skyirrad.txt file.  
c
c     The file containing the solar irradiance and atmospheric
c     absorption coefficients for O2, O3, and H20.  To be read
c     by routine lidata in grirrad.f:
c      gcifile = '..' // sysl // 'data' // sysl // 'gcirrad.txt'
c     by routine lidata_new in RADTRANX.f:
cJC      gcifile = '..' // sysl // 'data' // sysl // 'RADTRANX_dbase.txt'
      gcifile = dirEco(1:32) // sysl // 'data' //
     1                 sysl // 'RADTRANX_dbase.txt'
c
      iein = 0                  ! compute irradiances
      iblw = 0                  ! above-surface values
c
c-----  ERROR CRITERIA FOR ODE SOLVER  --------------------------
c
c     Set relative and absolute error criteria for the ODE solver.
c     the values 0.0001 and 0.001 are a reasonable balance between 
c     accuracy and run time.  Decrease (increase) the values for 
c     more (less) accuracy in the radiance solution, with a slower 
c     (faster) run time.  (used in routine riccati on file riccati.f)
c
      relerrs = 0.0001
      abserrs = 0.001
c
      fmisc(6) = relerrs
      fmisc(7) = abserrs
c
c     Set maximul allowed spacing of adjacent solution bands in ZETA
c     (optical depth).  Riccati.f will solve for additional intermediate
c     optical depths if needed.  This helps ensure good solutions when
c     output depths are widely spaced.
c
       fmisc(26) = 5.0e+00		!five optical depths
c-----------------------------------------------------------------
c-----  DEPTH INCREMENT FOR COMPUTING DEPTH DERIVATIVES (HL version ONLY)  -----------
c
c     deltazK is the small depth increment that is added to each
c     user-requested output depth for the purpose of computing 
c     K functions, which require closely spaced depths for proper 
c     estimation of depth derivatives.
      deltazK = 0.01       
      fmisc(10) = deltazK 
c
      return
      end
