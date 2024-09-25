******************************************************************************
* Author: 	Paul Madley-Dowd
* Date: 	19 January 2021
* Description:  Runs all global macros for the ALSPAC autism and depression project. To be run at the start of all stata sessions. 
******************************************************************************
clear 

global Projectdir "PROJECT_DIRECTORY_PATH"

global Gitdir 		"LOCAL_GITHUB_DIRECTORY_PATH" // update to your local github path
global Dodir 		"$Gitdir\dofiles"
global Logdir 		"$Projectdir\logfiles"
global Datadir 		"$Projectdir\datafiles"
global Rawdatdir 	"$Projectdir\rawdata"
global Graphdir 	"$Projectdir\graphfiles"

cd "$Projectdir"