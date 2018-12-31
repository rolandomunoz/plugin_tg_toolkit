form Read annotation files
  comment Folder with annotation files:
  text tg_folder /home/rolando/gdrive/proyectos/spanish/spanish_stops/voiced_stops/data
  comment Folder with sound files:
  text audio_folder . ( = Relative path)
  boolean Adjust_volume 1
  comment Table columns:
  natural File_name 10
  integer Start_time 6
  integer End_time 7
  integer Text 5
endform

tb = selected()
n_files = object[tb].nrow
file_number = 1
relative_path = if startsWith(audio_folder$, ".") then 1 else 0 fi
tg_ext$ = "TextGrid"
audio_ext$ = "wav"
volume = 0.99
pause = 1
buttonChoice = 3

while pause
  file_number = if file_number > n_files then 1 else file_number fi
  
  # Read from table
  tg$ = object$[tb, file_number, file_name]
  if not text
    text$ = object$[tb, file_number, text]
  endif
  
  # Get tg and sd fullpaths
  tg_full_path$ = tg_folder$ + "/" + tg$
  path$ = replace_regex$(tg_full_path$, "(.+)/(.+)", "\1", 1)
  basename$ = replace_regex$(tg_full_path$, "(.+)/(.+)", "\2", 1)
  sd$ = basename$ - tg_ext$ + audio_ext$

  if relative_path
    sound_full_path$ = path$ + "/" + audio_folder$ + "/" + sd$
  else
    sound_full_path$ = audio_folder$ + "/" + sd$
  endif

  tg = Read from file: tg_full_path$
  open_with_sound = if fileReadable(sound_full_path$) then 1 else 0 fi
  if open_with_sound
    if adjust_volume
      sd = Read from file: sound_full_path$
      Scale peak: volume
    else
      sd = Open long sound file: sound_full_path$
    endif
    objectList# = {sd, tg}
  else
    objectList# = {tg}
  endif

  selectObject: objectList#
  View & Edit
  editor: tg
  if start_time != 0 or end_time != 0
    tmin = object[tb, file_number, start_time]
    tmax = object[tb, file_number, end_time]

    dur = tmax - tmin
    dur_10 = dur*0.10
    Zoom: tmin - dur_10, tmax + dur_10
    Select: tmin, tmax
  endif
  
  beginPause: "file bfile_numberser"
    comment: "Case: 'file_number'/'n_files'"
    natural: "Next file",  if (file_number + 1) > n_files then 1 else file_number + 1 fi
    if adjust_volume
      real: "Volume", volume
    endif
  clicked_pause = endPause: "Save", "Jump", "Quit", buttonChoice
  endeditor

  buttonChoice = clicked_pause 
  if clicked_pause = 1
    selectObject: tg
    Save as text file: tg_full_path$
  endif
  
  removeObject: objectList#
  file_number = next_file

  if clicked_pause = 3
    pause = 0
  endif
endwhile

selectObject: tb