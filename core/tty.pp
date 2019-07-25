unit tty;

interface

{$mode objfpc}{$modeSwitch advancedRecords}

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
  private
    FConsoleChar: char;
    FCharColor: byte;
  public
    class function New(newConsoleChar: char; newCharColor: TConsoleColor): TConsoleChar; static;
    property ConsoleChar: char read FConsoleChar write FConsoleChar;
    property CharColor: byte read FCharColor write FCharColor;
  end;
  PConsolePosition = ^TConsolePosition;

  TConsolePosition = packed record
    Position: array[0..ConsoleYMax, 0..ConsoleXMax] of TConsoleChar;
  end;

  Console = record
  private
    class var
    ColorBrush: TConsoleColor;
    Cursor: record
      X, Y: smallint;
    end;
  public
    class function Move(X, Y: smallint): Console; static;
    class function ScrollDown: Console; static;
    class function SetColor(Color: TConsoleColor): Console; static;
    class function Line: Console; static; inline;
    class function Clear: Console; static;
    class function Print(c: char): Console; static; overload;
    class function Print(c: pchar): Console; static; overload; 
    class function Print(i: Integer): Console; static; overload; 
  end;

implementation

var
  VideoMemory: PConsolePosition = PConsolePosition($b8000);

class function TConsoleChar.New(newConsoleChar: char; newCharColor: TConsoleColor): TConsoleChar;
begin
  result.FConsoleChar := newConsoleChar;
  result.FCharColor := byte(newCharColor);
end;

class function Console.Move(X: smallint; Y: smallint): Console;
begin
  if X < 80 then
    Cursor.X := X
  else
    Move(0, Y + 1);
  if Y < 24 then
    Cursor.Y := Y
  else
    Console.ScrollDown;
end;

class function Console.ScrollDown: Console;
var
  i, j: smallint;
begin
  for j := 0 to ConsoleYMax do
    for i := 0 to ConsoleXMax do
      VideoMemory^.Position[j][i] := VideoMemory^.Position[j + 1][i];
  Move(0, 23);
end;

class function Console.SetColor(Color: TConsoleColor): Console;
begin
  ColorBrush := Color;
end;

class function Console.Line: Console;
begin
  Move(0,Cursor.Y + 1);
end;

class function Console.Clear: Console;
var
  loop: smallint;
begin
  for loop := 0 to 24 do Console.ScrollDown;  
  Move(0,0);
end;

class function Console.Print(c: char): Console;
begin
  VideoMemory^.Position[Cursor.Y, Cursor.X] := TConsoleChar.New(c, ColorBrush);
  Console.Move(Cursor.X + 1, Cursor.Y);
end;

class function Console.Print(c: pchar): Console;
begin
  while c^ <> #0 do begin
    Console.Print(c^);
    inc(c);
  end;    
end;

class function Console.Print(i: Integer): Console; static;
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
        Console.Print(str);
end;

end.