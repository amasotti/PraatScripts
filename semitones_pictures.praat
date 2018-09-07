####################################################################
# This script is distributed under the GNU General Public License. 
# Copyright 10.05.2018 - Antonio Masotti
#
# many thanks to Prof. Stavros Skopeteas for the useful suggestions
####################################################################

form Formantanalyse
	comment Where are the sound files?
	text sound_directory C:\test\
	sentence Sound_file_extension .WAV
	comment Where are the TextGrids?
	text textGrid_directory C:\test\
	comment Save the pictures in the following directory:
	text picture_directory C:\test\pictures\
	sentence TextGrid_file_extension .TextGrid

	comment Which tier should I analyze?
	sentence Tier vowels

	comment Parameter for Pitch analysis
	positive pitch-ceiling 350
	positive pitch-floor 75
	positive maximum-formant 4000	
	comment Parameter for the Plots
	real x-max 8
	real y-max 4
	positive line-width 2
endform

Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings


select Strings list

for ifile to numberOfFiles
	filename$ = Get string... ifile
	Read from file... 'sound_directory$''filename$'
	soundname$ = selected$ ("Sound", 1)
	select Sound 'soundname$'
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_file_extension$'"
	if fileReadable (gridfile$)
		Read from file... 'gridfile$'
		call GetTier 'tier$' tier
		numberOfIntervals = Get number of intervals... tier
		for interval to numberOfIntervals
			label$ = Get label of interval... tier interval
			# ignore empty intervals
			if label$ <> ""
			start = Get starting point... tier interval
			end = Get end point... tier interval
			select Sound 'soundname$'
			To Pitch: 0, 'pitch-floor', 'pitch-ceiling'
			Erase all
			Black
			Line width: 'line-width'
			Solid line
			Blue
			10
			Speckle size: 0.5
			Select outer viewport: 0, 'x-max', 0, 'y-max'
			Blue
			Line width: 'line-width'
			Draw semitones (re 100 Hz): start, end, -12, 30, "no"
			#Draw: start, end, 0, 'pitch-ceiling', "no"
			#Marks bottom every: 3, 0.5, "no", "yes", "yes"
			Marks left every: 0.5, 5, "yes", "yes", "yes"
			#Logarithmic marks left: 3, "yes", "yes", "yes"
			Black
			Text left: "yes", "re semitones (1 Hz)"
			Select outer viewport: 0, 'x-max', 0, 'y-max'
			Draw inner box
			y = 'y-max' - 0.5
			y2 = 'y-max' + 3.5
			Select outer viewport: 0, 'x-max', y, y2
			
			select Sound 'soundname$'
			plusObject: "TextGrid 'soundname$'"

			Draw: start, end, "yes", "yes", "yes"
			Select outer viewport: 0, 'x-max', 0, y2
			Draw inner box
			indice$ = "seq" + "'interval'"
			salva$ = "'picture_directory$''soundname$'" + "_dan_tier" + "_" + "'indice$'" + ".png"
			Save as 300-dpi PNG file: salva$
			selectObject: "Pitch 'soundname$'"
			Remove
			selectObject: "TextGrid 'soundname$'"
endif
endfor
selectObject: "TextGrid 'soundname$'"
Remove
select Strings list
endfor
SelectObject: "Sound 'soundname$'"
Remove
select Strings list
Remove


#-------------
# This procedure finds the number of a tier that has a given label.

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
