unit console;

interface

{$modeSwitch advancedRecords}

const
  ConsoleXMax = 79;
  ConsoleYMax = 23;

type
  TConsoleColor = ( //fpOS type
    ccBlack, ccBlue, ccGreen, ccCyan,
    ccRed, ccMagenta, ccBrown, ccLightGrey,
    ccDarkGrey, ccLightBlue, ccLightGreen, ccLightCyan,
    ccLightRed, ccLightMagenta, ccLightBrown, ccWhite
    );
PConsoleChar = ^TConsoleChar;
  TConsoleChar = packed record
    ConsoleChar: Char;
    CharColor: byte;
  end;
PConsolePosition = ^TConsolePosition;
TConsolePosition = packed record
  Position: array[0..ConsoleYMax] of array[0..ConsoleXMax] of TConsoleChar;
end;

  { TConsole }

  TConsole = record
procedure Create();
procedure ClearScreen();
procedure Write(x: Char); overload;
procedure Write(x: pchar); overload;
procedure Write(x: integer); overload;
procedure Write(x: dword); overload;
procedure Write(x: Char; nextLine: boolean); overload;
procedure Write(x: pchar; nextLine: boolean); overload;
procedure Write(x: integer; nextLine: boolean); overload;
procedure Write(x: dword; nextLine: boolean); overload;
procedure WriteChar(c: Char);
//procedure WriteString(s: PChar); overload;
//procedure WriteString(Str: PChar; nextLine: boolean); overload;
function WriteString(Str: PChar): TConsole; overload;
procedure WriteInt(i: Integer);
procedure WriteDword(i: DWORD);
procedure Move(const X, Y: word);
procedure ScrollDown;
private
  ColorBrush: TConsoleColor;
  Cursor: record
    X, Y: word;
   end;
  procedure Ln;
  procedure WriteString(Str: string; nextLine: boolean);
end;

implementation

var
        VideoMemory: PConsolePosition = PConsolePosition($b8000);

procedure TConsole.ScrollDown;
var
  i, j: byte;
begin
  for j := 0 to ConsoleYMax do
  for i := 0 to ConsoleXMax do
    VideoMemory^.Position[j][i] := VideoMemory^.Position[j+1][i];
    Move(0,23);
end;

procedure TConsole.WriteChar(c: Char);
type pword = ^word;
var
  X: TConsoleChar;
begin
  case C of
    #13: Ln;
    else

  with X do begin
    ConsoleChar:= c;
    CharColor:= byte(ColorBrush);
  end;
  //PDWord(pchar(VideoMemory) + Cursor.X+Cursor.Y)^ := Dword(((byte(colorBrush) shl 8)) or byte(c));
  VideoMemory^.Position[Cursor.Y][Cursor.X] := X;
  Move(Cursor.X + 1, Cursor.Y);
  end;
end;

procedure TConsole.Move(const X, Y: word);
begin
  if X < 80 then
    Cursor.X := X
    else Move(0, Y +1);
  if Y < 24 then
    Cursor.Y := Y 
  else ScrollDown;
end;

procedure TConsole.Ln;
begin
    Move(0,Cursor.Y + 1);
end;

procedure TConsole.Write(x: Char); overload;
begin
  WriteChar(x);
end;

procedure TConsole.Write(x: pchar); overload;
begin
  WriteString(x);
end;

procedure TConsole.Write(x: integer); overload;
begin
  WriteInt(x);
end;

procedure TConsole.Write(x: dword); overload;
begin
  WriteDword(x);
end;

procedure TConsole.Write(x: Char; nextLine: boolean); overload;
begin
  WriteChar(x);
  if nextLine then Ln;
end;

procedure TConsole.Write(x: pchar; nextLine: boolean); overload;
begin
  WriteString(x);
  if nextLine then Ln;
end;

procedure TConsole.Write(x: integer; nextLine: boolean); overload;
begin
  WriteInt(x);
  if nextLine then Ln;
end;

procedure TConsole.Write(x: dword; nextLine: boolean); overload;
begin
  WriteDword(x);
  if nextLine then Ln;
end;

procedure TConsole.Create();
begin
  ClearScreen;
  ColorBrush := ccLightGrey;
  Cursor.X := 0;
  Cursor.Y := 0;
end;

procedure TConsole.ClearScreen(); [public, alias: 'clearscreen'];
var
 i: smallint;
begin
 for I := 0 to 24 do ScrollDown;
end;


function TConsole.WriteString(Str: PChar): TConsole;
begin
  WriteString(s,false);
  result := self;
end;

procedure TConsole.WriteString(Str: string; nextLine: boolean); overload; [public, alias: 'kwritestr'];
var
  i: word = 1;
begin
 {
  repeat begin
    WriteChar(Str^);
    Inc(Str);
  end until (Str^ = #0);
  }
  repeat begin
    WriteChar(Str[1]);
    Inc(Str);
  end until (Str[1] = #0);
end;

procedure TConsole.WriteInt(i: Integer); [public, alias: 'kwriteint'];
var
        buffer: array [0..11] of Char;
        str: PChar;
        digit: DWORD;
        minus: Boolean;
begin
        str := @buffer[11];
        str^ := #0;

        if (i < 0) then
        begin
                digit := -i;
                minus := True;
        end
        else
        begin
                digit := i;
                minus := False;
        end;

        repeat
                Dec(str);
                str^ := Char((digit mod 10) + Byte('0'));
                digit := digit div 10;
        until (digit = 0);

        if (minus) then
        begin
                Dec(str);
                str^ := '-';
        end;

        WriteString(str);
end;

procedure TConsole.WriteDword(i: DWORD); [public, alias: 'kwritedword'];
var
        buffer: array [0..11] of Char;
        str: PChar;
        digit: DWORD;
begin
        for digit := 0 to 10 do
                buffer[digit] := '0';

        str := @buffer[11];
        str^ := #0;

        digit := i;
        repeat
                Dec(str);
                str^ := Char((digit mod 10) + Byte('0'));
                digit := digit div 10;
        until (digit = 0);

        WriteString(@Buffer[0]);
end;

end.
