program pdf_library
implicit none

! Defining variables
character(20) :: datafile
character(200) :: path
character(10) :: reader

character :: opt
character(50) :: str

! Initializing variables
opt = "s"
call read_settings()
reader = 'okular'

do while (opt .ne. "Q" .and. opt .ne. "q")
  call initial_screen()
  read(*,*) opt
  select case (opt)
    case("1")
      call search()
    case("2")
      call search_inside()
    case("3")
      call bib_search()
    case("4")
      call bib_create()
    case("5")
      call OCR()
    case("B","b")
      call choose_DB()
    case("C", "c")
      call show_settings()
    case("D", "d")
      call show_deps()
    case("P", "p")
      call show_appPDF()
  end select
  print*
end do

contains

subroutine initial_screen()
implicit none
call system("clear")
print*, '============================================================='
print*, '||                                                         ||'
print*, "|| Catalog of papers, articles, books and other documents. ||"
print*, '|| Developed by: Andre Herman                              ||'
print*, "||                                                         ||"
print*, "============================================================="
print*
print*, " Choose an option:"
print*, " [1] Search by author or title"
print*, " [2] Search string inside text"
print*, " [3] Make a BiBTex search (online)"
print*, " [4] Create a BiBTex file (soon)"
print*, " [5] OCR all PDF's"
print*
print*, " [B] Choose database"
print*, " [C] View/Change settings"
print*, " [D] View program dependencies"
print*, " [P] Change PDF reader"
print*, " [Q] Quit"
print*
write(*,'(A)',advance='no') '   => '
end subroutine

subroutine search()
implicit none
  character(500) :: cmd
  character(250) :: cmd1, cmd2
  character(4) :: slc

  slc = "I"
  call system("clear")
  print*, "Type the search string:"
  read(*,'(A)') str
  print*
 
  ! fixed cmd1 and cmd2
  cmd1 = 'cat '//datafile//' | grep -i ' // str
  cmd2 = ' | awk ''BEGIN{FS=";"}{printf "[%4s]%-10s%-7s%-81.81s %-4s %-52.52s\n",  $1,$2,$3,$4,$6,$5}'''
  
  do while (slc .ne. "Q" .and. slc .ne. "q")
    call system("clear")
    print*, 'SEARCH STRING: '//str
    print*, 'Files found:'
    print*
    
    select case (slc)
      ! default. Sort by id
      case("I", "i")
        cmd = trim(adjustl(cmd1)) // ' | sort -t '';'' -nbk1' //  trim(adjustl(cmd2))
        call system(cmd)
        print*
        call prompt_search()
        read(*,*) slc
      
      ! sort by title
      case("T","t")
	print*, 'SORTED BY TITLE'
	print*
	cmd = trim(adjustl(cmd1))//' | sort -t '';'' -bk4'//trim(adjustl(cmd2))
	call system(cmd)
	print*
	call prompt_search()
	read(*,*) slc
      
      ! sort by year
      case("Y","y")
	print*, 'SORTED BY YEAR'
	print*
	cmd = trim(adjustl(cmd1)) // ' | sort -t '';'' -nbk6' // trim(adjustl(cmd2))
	call system(cmd)
	print*
	call prompt_search()
	read(*,*) slc

      ! sort by author
      case("A","a")
	print*, 'SORTED BY AUTHOR'
	print*
	cmd = trim(adjustl(cmd1)) // ' | sort -t '';'' -bk5' // trim(adjustl(cmd2))
	call system(cmd)
	print*
	call prompt_search()
	read(*,*) slc
    
      ! quit to menu
      case("Q","q")
        print*
        read(*,*) slc

      ! add to bib file
      !case("+")
      !  print*, "Added to bibfile" 
      !  read(*,*) slc

      ! open the file
      case default
	! -- In this command, the id must be the same as the filename.
	! -- To improve the code, a search for the right file with the given id must be made.
        !cmd = 'evince '//trim(adjustl(path))//'`cat '//datafile//' | grep -i '''//trim(adjustl(slc))//';'' | awk ''BEGIN{FS=";"}{print $2}'' | head -1`'
        cmd = reader//' '//trim(adjustl(path))//'`cat '//datafile//' | grep -i '''// &
           trim(adjustl(slc))//';'' | awk ''BEGIN{FS=";"}{print $2}'' | head -1`'//"& > /dev/null 2>&1"
        print*, cmd
	call system(cmd)
	slc = "I"
    end select
  end do
  slc = ''
end subroutine

subroutine search_inside()
implicit none
  character(500) :: cmd
  
  call system("clear")
  print*, "Usage:"
  print*, "'Arrow keys' to navigate through the results list;" 
  print*, "'Space key' to scrool several lines at once;"
  print*, "To quit the results list, hit 'q'."
  print*
  print*, "Put an '*' at the end of the string to show all results that &
     contains the string that you want. Ex.: solute* will show either solute, absolute, absolutely..."
  print*
  print*, "Type the search string:" 
  read(*,'(A)') str
  call system("clear")
  print*, "Searching the string through files. Wait until it finishes or hit ctrl+c to force stop."
  print*

  if (index(str,'*') > 0) then
    str = str(1:index(str,'*')-1)
    cmd = "find "//trim(adjustl(path))// &
      " -name '*.pdf' -exec sh -c 'pdftotext ""{}"" - | grep -i --with-filename --label=""{}"" --color=always """// &
      trim(adjustl(str))//"""' \; | less -r 2>/dev/null"
  else
    cmd = "find "//trim(adjustl(path))// &
      " -name '*.pdf' -exec sh -c 'pdftotext ""{}"" - | grep -i -w --with-filename --label=""{}"" --color=always """// &
      trim(adjustl(str))//"""' \; | less -r 2>/dev/null"
  endif
  print*, cmd
  call system(cmd)
  print*
  print*, "Search is over. Hit any key to return to menu."
  read(*,*) 
end subroutine

subroutine choose_DB()
implicit none
  character(200) :: cmd
  character(2)   :: slc

  print*
  print*, " Choose database"
  print*
  cmd = 'ls -l *.dat | awk ''BEGIN{i=1} {print "  ["i"]",$9; i++}'''
  call system(cmd)
  write(*,'(A)',advance='no') '   => '
  read(*,*) slc
!  cmd = 'sed ''1 c\ `ls -l *.dat | awk ''BEGIN{i=1} {print "  ["i"]",$9; i++}'' | awk ''NR=='//slc//' {print $2}''` settings.in'
  cmd = "sed -i '1s/.*/'""`ls -l *.dat | awk 'BEGIN{i=1} {print ""[""i""]"",$9; i++}' | awk 'NR=="// &
    slc//" {print ""\042""$2""\042""}'`""'/' settings.in" 
  call system(cmd)
  call read_settings()
  print*
  write(*,'(A)') "Type the complete path to the PDF files of that database (ex. /home/user/PDF_database/):"
  read(*,*) path
  cmd = "sed -i '2s/.*/"//path//"/' settings.in" 
  call system(cmd)
end subroutine

subroutine show_appPDF()
implicit none
character(1) :: slc

  print*
  print*, " Choose a PDF reader"
  print*
  print*, " [1] Evince"
  print*, " [2] Okular"
  write(*,'(A)',advance='no') '   => '
  read(*,*) slc
  if (slc .eq. "1") then
    reader = 'evince'
  else if (slc .eq. "2") then
    reader = 'okular'
  endif
end subroutine

subroutine bib_search()
implicit none
  character(100) :: query
  character :: opt
  
  call system("clear")
  write(*,*) 'You must select the right BiBTeX info about your paper/thesis/book.'
  write(*,*) 'HINT: Look at the author''s name and publication year.'
  print*
  write(*,'(A)', advance='no') "Type the title of the paper/thesis/book to find and create a .bib file (use '+' instead of space):"
  print*
  read(*,*) query
  call system("./get_ref.sh "//query)
  print*
  write(*,*) 'The BibTex reference has been saved in ''library.bib'' file.'
  read(*,*)
end subroutine

subroutine bib_create()
implicit none
  character(500) :: cmd1,cmd2,cmd

  call system("clear")
  cmd1 = 'cat '//datafile
  cmd2 = ' | awk ''BEGIN{FS=";"}{printf "[%4s]%-10s%-7s%-81.81s %-4s %-52.52s\n",  $1,$2,$3,$4,$6,$5}'''
  cmd = trim(adjustl(cmd1)) // ' | sort -t '';'' -nbk1' //  trim(adjustl(cmd2))
  call system(cmd)
  print*
  print*, "Type the file number(s) that you want to add as a BiBTeX entry in the "// &
    "bib file"
  read(*,*)

end subroutine

subroutine OCR()
implicit none
  character (500) :: cmd

  !creates a txt file with all pdf filenames (full extension)
  cmd = 'ls '//trim(adjustl(path))//'*.pdf > filenames.txt'
  call system(cmd)
  !OCRs all PDF files and save with same filename and txt extension
  cmd = 'for line in $(cat filenames.txt);do echo "OCRing ${line}...";pdftotext ${line} ${line}.txt;echo "done!";done'
  call system(cmd)
  cmd = 'echo;echo "All files OCRed! Press any key to go to menu."; rm filenames.txt'
  call system(cmd)
  read(*,*)
end subroutine

subroutine show_settings()
implicit none
  call system("clear")
  print*, "-== Current settings: ==-"
  print*
  write(*,*) "Name of database file: ", trim(adjustl(datafile))//''
  write(*,*) "Path to PDF files: ", trim(adjustl(path))//''
  read(*,*)
end subroutine

subroutine show_deps()
implicit none
  call system("clear")
  print*, '-== Dependencies ==-'
  print*, 'awk'
  print*, 'lynx'
  print*, 'vim'
  print*, 'curl'
  print*, 'evince'
  print*, 'okular'
  print*, 'pdftotext'
  print*
  print*, 'Without these programs, the application doesn''t run properly.'
  read(*,*)
    
end subroutine

subroutine read_settings()
implicit none
  open(100,file='settings.in')
  read(100,*) datafile
  read(100,*) path
  close(100)
end subroutine

subroutine prompt_search()
  write(*,'(A)',advance='no') 'Type: [number] to open file    Sort by: [Y]ear, [T]itle, [I]d, [A]uthor    [Q] go to menu  => '
end subroutine

end program
