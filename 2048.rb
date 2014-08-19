DI = {'right'=>{r:0,c:1},
      'left' =>{r:0,c:-1},
      'down' =>{r:1,c:0},
      'up'   =>{r:-1,c:0},
     }
def init_color
    Curses.init_pair(COLOR_BLUE ,COLOR_BLUE,COLOR_BLACK)
    Curses.init_pair(COLOR_RED,COLOR_RED,COLOR_BLACK)
    Curses.init_pair(COLOR_CYAN,COLOR_CYAN,COLOR_BLACK)
    Curses.init_pair(COLOR_GREEN,COLOR_GREEN,COLOR_BLACK)
    Curses.init_pair(COLOR_MAGENTA,COLOR_MAGENTA,COLOR_BLACK)
    Curses.init_pair(COLOR_YELLOW,COLOR_YELLOW,COLOR_BLACK)
    Curses.init_pair(COLOR_WHITE,COLOR_WHITE,COLOR_BLACK)
end
def get_color(value)
    color=[COLOR_WHITE,
        COLOR_GREEN  , 
     COLOR_BLUE   , 
     COLOR_RED    , 
     COLOR_CYAN   , 
     COLOR_MAGENTA, 
     COLOR_YELLOW ]
     if value == 0
        return COLOR_WHITE
     end
     v = Math.log(value,2).to_i
    return color[v%7]
end
def moveright(array,type,di)
    n = array.length
    (n-1).downto(0) do |c|
        for r in (0..n) do
            modify_array(r,c,array,type,di)
        end
    end
end
def moveleft(array,type,di)
    n = array.length
    (0).upto(n-1) do |c|
        for r in (0...n) do
            modify_array(r,c,array,type,di)
        end
    end
end
def moveup(array,type,di)
    n = array.length
    (0).upto(n-1) do |r|
        for c in (0...n) do
            modify_array(r,c,array,type,di)
        end
    end
end
def movedown(array,type,di)
    n = array.length
    (n-1).downto(0) do |r|
        for c in (0...n) do
           modify_array(r,c,array,type,di)
        end
    end
end
def modify_array(r,c,array,type,di)
    n = array.length
    x,y = r,c
    while((x+di[:r]).between?(0,n-1)  and 
          (y+di[:c]).between?(0,n-1)  and
         (array[x+di[:r]][y+di[:c]]==0)) do 
        array[x][y],array[x+di[:r]][y+di[:c]]=array[x+di[:r]][y+di[:c]],array[x][y]
        x+=di[:r]
        y+=di[:c]
    end
    if ((x+di[:r]).between?(0,n-1)  and 
          (y+di[:c]).between?(0,n-1) and 
          array[x+di[:r]][y+di[:c]]==array[x][y] and 
          type[x+di[:r]][y+di[:c]])
        array[x+di[:r]][y+di[:c]]+=array[x][y]
        type[x+di[:r]][y+di[:c]] = false
        array[x][y]=0
    end
end
def put_result(array,win)
    color={}
    n = array.length
        for rr in  (0...n) do
            str=''
            for cc in (0...n) do 
                str=sprintf("%10d",array[rr][cc])
                #puts get_color(array[rr][cc])
                win.attron(color_pair(get_color(array[rr][cc]))){
                    win.setpos(rr+1,cc*10+1)
                    win.addstr(str)
                }
            end
        #puts str
        #win.setpos(rr+1,1)
        #win.addstr(str)
        win.refresh
    end
end
def set_rand(array)
    count =0
    array.each {|row| row.each{|x|count+=1 if x!=0  }}
    if (count<array.length*array.length)
        x=rand(array.length)
        y=rand(array.length)
        while(array[x][y]!=0) do
            x=rand(array.length)
            y=rand(array.length)
        end
        tmp=rand(2)
        array[x][y]=2+2*tmp
        count +=1
    end
end
def reset(type)
    for i in (0...type.length) do
        for j in (0...type.length) do
            type[i][j]=true
        end
    end
end
require 'curses'
include Curses
    array=[]
    type=[]
    puts('Please input size:')
    n=gets().to_i
    init_screen()
    noecho()
    crmode
    start_color
    init_color()
    #Curses.init_pair(COLOR_BLUE,COLOR_BLUE,COLOR_BLACK) 
    #Curses.init_pair(COLOR_RED,COLOR_RED,COLOR_BLACK)
    win = Curses::Window.new( n+2, n*10+2,
                          0,0 )
    win.box("|", "-")
    win.keypad(true)
   for i in  (0...n) do 
      tmp =[]
      n.times {tmp.push(0)}
      array[i]=tmp
      tmp =[]
      n.times {tmp.push(true)}
      type[i]=tmp
   end
   set_rand(array)
   set_rand(array)
   put_result(array,win)
   while(true) do
    d= win.getch
    exit() if d=='q'
    #puts (d)
    #d=[Curses::Key::UP,Curses::Key::DOWN,Curses::Key::LEFT,Curses::Key::RIGHT][rand(5)]
    direction = 'up' if Curses::Key::UP== d 
    direction = 'down' if Curses::Key::DOWN== d 
    direction = 'left' if Curses::Key::LEFT== d 
    direction = 'right' if Curses::Key::RIGHT== d 
    reset(type)
    send("move#{direction}",array,type,DI[direction])
    set_rand(array)
    put_result(array,win)
   end