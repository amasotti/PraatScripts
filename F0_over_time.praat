####################################################################
# This script is distributed under the GNU General Public License. 
# Copyright 4.7.2003 Mietta Lennes				                         
#								                                                   
# heavly modified by Antonio Masotti 08.05.2018		
# thanks to Prof. S. Skopeteas for the useful suggestions and part of
#  the code
####################################################################

# Please change the paths of the directories
# and the names of the grids you want to analyze

form Formantanalyse
	comment Let's begin
	comment Where are the sound files?
	text sound_directory C:\
	sentence Sound_file_extension .wav
	comment Where are the TextGrids?
	text textGrid_directory C:\
	sentence TextGrid_file_extension .TextGrid
	comment Save the results as:
	text table_name Analisi_formante0
	comment Which tier should I analyze?
	sentence Tier vowels
	comment Formant Parameters:
	positive Time_step 0.01
	integer Maximum_number_of_formants 5
	positive Maximum_formant_(Hz) 4500
	positive Window_length_(s) 0.025
	real Preemphasis_from_(Hz) 50	
	comment Pitch Analysis:
	positive step 0.005
	real Pitch_floor_(Hz) 50
	real Pitch_ceiling_(Hz) 600
endform

# List all the files in the given directory
Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings

# Generate an empty table for the results
Create Table with column names... 'table_name$' 1 fileNome interval_label time itime f0 f1 f2 f3 
riga = 0
select Strings list

# First loop: it finds the sound files and begins the analysis
for ifile to numberOfFiles
	filename$ = Get string... ifile
	# open the ifile
	Read from file... 'sound_directory$''filename$'
	soundname$ = selected$ ("Sound", 1)
	select Sound 'soundname$'
	# Extract the formants with the "burg" method
	To Formant (burg)... time_step maximum_number_of_formants maximum_formant window_length preemphasis_from
	select Sound 'soundname$'
	# Extract the pitch
	To Pitch... step pitch_floor pitch_ceiling
	# Search for annotations in the TextGrid
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_file_extension$'"
	if fileReadable (gridfile$)
		Read from file... 'gridfile$'
		# The function "GetTier" searchs for the tier given in the first form
		call GetTier 'tier$' tier
		numberOfIntervals = Get number of intervals... tier
		# second loop: non-empty intervals are selected and analyzed
		for interval to numberOfIntervals
			label$ = Get label of interval... tier interval
			if label$ <> ""
				# save the time coordinates of the current interval
				start = Get starting point... tier interval
				end = Get end point... tier interval
				xtime = start 
				endcounter  = (end - start) / step
				contatore = 0
					# third loop: divide the current interval into pieces according to the "step" unit given in the form
          # save the values for pitch and formants for the single slices
					for itime from start to endcounter
						contatore = contatore +1
						select Formant 'soundname$'
						f1t = Get value at time... 1 xtime Hertz Linear
						# round the values to the second decimal place
						f1$ = fixed$(f1t, 2)
						f2t = Get value at time... 2 xtime Hertz Linear
						f2$ = fixed$(f2t, 2)
						f3t = Get value at time... 3 xtime Hertz Linear
						f3$ = fixed$(f3t, 2)
						select Pitch 'soundname$'
						ptt = Get value at time: xtime, "Hertz", "Linear"
						pt$ = fixed$(ptt, 2)
						xtimet$ = fixed$(xtime, 3)
						#itimet$ = fixed$(itime, 0)
						# Open the table and append the results
						select Table 'table_name$'
						riga = riga +1
						Append row
						Set string value... riga fileNome 'soundname$'
						Set string value... riga interval_label 'label$'
						Set string value... riga time 'xtimet$'
						Set string value... riga itime 'contatore'
						Set string value... riga f0 'pt$'
						Set string value... riga f1 'f1$'
						Set string value... riga f2 'f2$'
						Set string value... riga f3 'f3$'
						xtime = xtime + step		
						start = start + step	
					endfor
			endif
			select TextGrid 'soundname$'
	endfor
		# delete already analyzed files
	select TextGrid 'soundname$'
	Remove
	endif
	select Sound 'soundname$'
	plus Pitch 'soundname$'
	plus Formant 'soundname$'
	Remove
	select Strings list
	# the next, please! 
endfor

Remove


#------------- Function GetTier: searches for the relevant tier in the TextGrid ---------------

procedure GetTier name$ variable$
        numberOfTiers = Get number of tiers
        itier = 1
        repeat
                tier$ = Get tier name... itier
                itier = itier + 1
        until tier$ = name$ or itier > numberOfTiers
        if tier$ <> name$
                'variable$' = 0
        else
                'variable$' = itier - 1
        endif

	if 'variable$' = 0
		exit The tier called 'name$' is missing from the file 'soundname$'!
	endif

endproc
