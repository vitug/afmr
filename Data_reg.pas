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
Unit Data_reg;

interface

Uses basic, SysUtils;

type
  PTDataRegistry = ^TDataregistry;
  TDataRegistry = class(TModule)
  private
    FNoData: boolean;
  protected
    function F0(F: Byte): word;   virtual; 
    procedure F16(F: Byte; W: Word); virtual;
  public
    procedure Reset;
    function ReadData: word;
    function ServiceRread: Word;
    function SetQ: boolean;
    procedure WriteData(Data: word);
    procedure ServiceRset(Reg: word);
    procedure ServiceRreset(Reg: word);
  end;

implementation

//==================================================

function TDataregistry.ReadData: word;
var
  F0_:  word;
  i: integer;
  Hi, Low: byte;
begin
  FNoData := False;
  GTW;
  RGAS.Write((8 shl K) + 8);
  RGAM.Write(0);
  RGDS.Write(0);
  RGDM.Write(0);
  {delay(10);}
  GTW;
  F0_ := 0;
  i := 0;
  repeat
    i := i + 1;
    if i > 1000 then
    begin
     FNoData := True;
     break;
    end;
    RGAS.Write(AdrSIn);
    RGAM.Write(AdrM);
    {delay(1);}
    GTW;{not work without}
    Hi := RGDS.Read;
    Low := RGDS.Read;
    F0_ := (Hi shl 8) + Low;
  until F0_ <> 0;
  Result := F0_;
end;

//--------------------------------------------------

procedure TDataregistry.WriteData(Data: word);
begin
  F16(16, Data);
end;

//--------------------------------------------------

procedure TDataregistry.Reset;
begin
  F0(9);
end;

//--------------------------------------------------

procedure TDataregistry.ServiceRset(Reg: word);
begin
  SetA(9);
  F16(19, Reg);
  SetA(0);
end;

//--------------------------------------------------

procedure TDataregistry.ServiceRReset(Reg: word);
begin
  SetA(9);
  F16(23, Reg);
  SetA(0);
end;

//--------------------------------------------------

function TDataregistry.ServiceRread: word;
begin
  setA(9);
  Result := F0(1);
  setA(0);
end;

//--------------------------------------------------

function TDataregistry.SetQ: boolean;
begin
  F0(8);
end;

//--------------------------------------------------

function TDataregistry.F0(F: Byte): word;
var
  F0_: integer;
begin
  GTW;
  RGAS.Write((8 shl K) + 8);
  RGAM.Write(0);
  RGDS.Write(0);
  RGDM.Write(F);
  Delay(1);
  GTW;
  F0_ := 0;
  RGAS.Write(AdrSIn);
  RGAM.Write(AdrM);
  GTW;{not work without}
  F0_ := (RGDS.Read shl 8) + RGDM.Read;
  F0 := F0_;
end;

//--------------------------------------------------

procedure TDataRegistry.F16(F: Byte; W: Word);
begin
  GTW;
  RGAS.Write((8 shl K) + 8);
  RGAM.Write(0);
  RGDS.Write(0);
  RGDM.Write(F);
  Delay(1);
  GTW;
  RGAS.Write(AdrSOut);
  RGAM.Write(AdrM);
  RGDS.Write(Hi(W));
  RGDM.Write(Lo(W));
  Delay(1);
end;

//==================================================

end.{Unit}