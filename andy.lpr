{
/////////////////////////////////////////////////////////
//                                                     //
//               Freepascal Yann OS                    //
//                      kernel.pp                     //
//                                                     //
/////////////////////////////////////////////////////////
//
//      By:             Yann Cabral <yann@aluno.puc-rio.br>
//      License:        Public domain (for now)
//
}

unit andy;

{$asmmode intel}
{$mode objfpc}

interface

uses tty;


procedure kernelMain(mbinfo: pointer; mbmagic: DWORD); stdcall;

implementation

procedure loop; assembler;
asm
  @loop:
  jmp @loop;
end;

procedure kernelMain(mbinfo: pointer; mbmagic: DWORD); stdcall; [public, alias: 'kernelMain'];
begin
  Console.Clear;
  Console.SetColor(ccLightGrey);
  Console.Print('Y').Print('a').Print('n').Print('n').Line;
  Console.Print('testando').Line;
  Console.Print(255).Line;
  Console.Print($F222F0);
  loop;
end;

end.

