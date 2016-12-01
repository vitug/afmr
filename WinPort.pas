{************************************************************}
{                                                            }
{                 ������ ���                                 }
{       Copyright (c) 2001  ��� ����                         }
{               �����/������                                 }
{                                                            }
{  �����������: �� ��                                        }
{  �������������: 25 ���� 2001                               }
{                                                            }
{************************************************************}
unit WinPort;

interface
uses
  Windows, SysUtils;

type
  Tport = class
  private
    Faddr: word;
    FStatus: boolean;
  public
    constructor CreatePort(address: word);
    procedure Write(data: byte);
    function  Read: byte;
    property Status: boolean read FStatus;
  end;

implementation

uses
  Main;

//==================================================

constructor Tport.CreatePort(address: word);
begin
  {Faddr := address;
  MainForm.DLPort.OpenDriver();
  if MainForm.DLPort.ActiveHW then
    FStatus := True
  else
    FStatus := False;}
end;

//--------------------------------------------------

procedure Tport.Write(data: byte);
var
  d: byte;
  s: String;
  dec, hex: integer;

begin
  if FStatus then
  begin
    d := data;
  // ������������ HEX �����
    dec := Faddr;
    s := '$' + IntToHex(dec, hex);
    Faddr := word(StrToInt(s));
  // ����� � ����, ��� addr � ������� HEX
    //MainForm.DLPort.Port[Faddr] := d;
  end;
end;

//--------------------------------------------------

function  Tport.Read: byte;
var
  d: byte;
  s: String;
  dec, hex: integer;
begin
  Result := 0;
  if FStatus then
  begin
  // ������������ HEX �����
    dec := Faddr;
    s := '$' + IntToHex(dec, hex);
    Faddr := word(StrToInt(s));
  // ������ �� �����, ��� addr � ������� HEX
    //d := MainForm.DLPort.Port[Faddr];
    Result := d;
  end;
end;

end.
