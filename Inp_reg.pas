{************************************************************}
{                                                            }
{                 Модуль ХХХ                                 }
{       Copyright (c) 2001  ООО ХХХХ                         }
{               отдел/сектор                                 }
{                                                            }
{  Разработчик: ХХ ХХ                                        }
{  Модифицирован: 25 июня 2001                               }
{                                                            }
{************************************************************}
Unit Inp_Reg;{Polon}

interface

uses
  Basic,
  SysUtils;

type
    PTInputRegistry = ^TInputRegistry;
    TInputRegistry = class(TModule)
    private
      FNoData: boolean;
    public
      constructor Init(NM: byte);
      procedure Reset;
      function ReadData(NumberReg: byte): longint;
      function StrobReadData(NumberReg: byte): longint;
      procedure Strob(NumberReg: byte);
      property NoData: boolean read FNoData write FNoData; 
    end;

implementation

//==================================================

constructor TInputRegistry.Init(NM: byte);
begin
  inherited
     Init('TInputRegistry', NM, CrateCannel);
  Reset;
  Delay(100);
end;

//--------------------------------------------------

procedure TInputRegistry.Reset;
begin
  SetA(0);
  ServiceF(9);
  Delay(100);
end;

//--------------------------------------------------

function TInputRegistry.ReadData(NumberReg: byte): longint;
var
  F0_: longint;
  i: integer;
begin
  {Reset;}
  SetA(NumberReg);
  F0_ := 0;
  i := 0;
  repeat
    inc(i);
    if i > 10 then
    begin
      FNoData := True;
      break;
    end;
    F0_ := Read24(0);
  until F0_ <> 0;
  ReadData := F0_;
  SetA(0);
end;

//--------------------------------------------------

function TInputRegistry.StrobReadData(NumberReg: byte): longint;
begin
  Strob(NumberReg);
  StrobReadData := ReadData(NumberReg);
end;

//--------------------------------------------------

procedure TInputRegistry.Strob(NumberReg: byte);
begin
  SetA(NumberReg);
  ServiceF(25);
  SetA(0);
end;

//==================================================

end.