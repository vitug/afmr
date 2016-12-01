//*** TDLPortIO: DriverLINX Port IO Driver wrapper component DEMO ************
//**                                                                        **
//** File: Main.pas                                                         **
//**                                                                        **
//** Copyright (c) 1999 John Pappas (DiskDude). All rights reserved.        **
//**     This software is CardWare; if you use it, you must send me a       **
//**     PostCard - see the documentation, or contact me for more           **
//**     information.                                                       **
//**                                                                        **
//**     Please notify me if you make any changes to this file.             **
//**     Email: diskdude@poboxes.com                                        **
//**                                                                        **
//*** http://diskdude.cjb.net/ ***********************************************

unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  PortIO, StdCtrls;

//---------------------------------------------------------------------------
// Types
//---------------------------------------------------------------------------

type
   TBase = (bDecimal, bHex);
   TDataType = (dtByte, dtWord, dtDWord);

  
//---------------------------------------------------------------------------
// TMain_Win class
//---------------------------------------------------------------------------

type
  TMain_Win = class(TForm)
    QuitButton: TButton;
    PortGroup: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    PortEdit: TEdit;
    ReadButton: TButton;
    WriteButton: TButton;
    DataEdit: TEdit;
    BaseGroup: TGroupBox;
    Base10Radio: TRadioButton;
    Base16Radio: TRadioButton;
    TypeGroup: TGroupBox;
    ByteRadio: TRadioButton;
    WordRadio: TRadioButton;
    DWordRadio: TRadioButton;
    AboutButton: TButton;
    DLPortIO: TDLPortIO;
    procedure AboutButtonClick(Sender: TObject);
    procedure Base10RadioClick(Sender: TObject);
    procedure Base16RadioClick(Sender: TObject);
    procedure QuitButtonClick(Sender: TObject);
    procedure ReadButtonClick(Sender: TObject);
    procedure WriteButtonClick(Sender: TObject);
    procedure ByteRadioClick(Sender: TObject);
    procedure WordRadioClick(Sender: TObject);
    procedure DWordRadioClick(Sender: TObject);
  private
    { Private declarations }
    FBaseMode : TBase;
    FDataType : TDataType;

  public
    { Public declarations }
    constructor Create(Owner : TComponent); override;
  end;

var
  Main_Win: TMain_Win;

implementation

{$R *.DFM}

//---------------------------------------------------------------------------
// Constructor for TMain_Win
//---------------------------------------------------------------------------
constructor TMain_Win.Create(Owner : TComponent);
begin
   inherited Create(Owner);

   FBaseMode:=bHex;   // Hex mode as default
   FDataType:=dtByte; // Byte mode as default

   // Default port
   PortEdit.Text:='$378'; // LPT1:
   DataEdit.Text:='$00';

   // Driver is in the same directory as the demo.exe file!
   DLPortIO.DriverPath:=ExtractFileDir(ParamStr(0));
   // Open the DriverLINX driver
   DLPortIO.OpenDriver();
   if (not DLPortIO.ActiveHW) then
   begin
      MessageDlg('Could not open the DriverLINX driver.', mtError, [mbOK], 0);
      PortGroup.Enabled:=false;
      BaseGroup.Enabled:=false;
      TypeGroup.Enabled:=false;
   end;
end;

//---------------------------------------------------------------------------
// Base10RadioClick()
//    Change the base of the edit boxes to decimal
//---------------------------------------------------------------------------
procedure TMain_Win.Base10RadioClick(Sender: TObject);
begin
   if (FBaseMode<>bDecimal) then
   begin
      // Now in decimal mode
      FBaseMode:=bDecimal;
      try
         PortEdit.Text:=IntToStr(StrToInt(PortEdit.Text));
      except
         PortEdit.Text:='0';
      end;

      try
         DataEdit.Text:=IntToStr(StrToInt(DataEdit.Text));
      except
         DataEdit.Text:='0';
      end;
   end;
end;

//---------------------------------------------------------------------------
// Base16RadioClick()
//    Change the base of the edit boxes to hex
//---------------------------------------------------------------------------
procedure TMain_Win.Base16RadioClick(Sender: TObject);
begin
   if (FBaseMode<>bHex) then
   begin
      // Now in hex mode
      FBaseMode:=bHex;
      try
         PortEdit.Text:='$'+IntToHex(StrToInt(PortEdit.Text),0);
      except
         DataEdit.Text:='$0000';
      end;

      try
         DataEdit.Text:='$'+IntToHex(StrToInt(DataEdit.Text),0);
      except
         DataEdit.Text:='$00';
      end;
   end;
end;

//---------------------------------------------------------------------------
// QuitButtonClick()
//    Quit the demo
//---------------------------------------------------------------------------
procedure TMain_Win.QuitButtonClick(Sender: TObject);
begin
   Close;
end;

//---------------------------------------------------------------------------
// ReadButtonClick()
//    Reads a byte into the DataEdit box
//---------------------------------------------------------------------------
procedure TMain_Win.ReadButtonClick(Sender: TObject);
var
   DataPort : Word;     // Port to read data from
   DataRead : Longword; // Data read from port
begin
   // Get the data port address
   try
      DataPort:=Word(StrToInt(PortEdit.Text));
   except
      MessageDlg('You have specified an invalid port.'+#13+
                 'No action performed.',
                 mtError, [mbOK], 0);
      Exit;
   end;

   // Read the data
   case FDataType of
      dtByte:  DataRead:=DLPortIO.Port[DataPort];
      dtWord:  DataRead:=DLPortIO.PortW[DataPort];
      dtDWord: DataRead:=DLPortIO.PortL[DataPort];
   end;

   if (FBaseMode=bDecimal) then
      DataEdit.Text:=IntToStr(DataRead)
   else
      DataEdit.Text:='$'+IntToHex(DataRead, 0);
end;

//---------------------------------------------------------------------------
// WriteButtonClick()
//    Writes a byte of data from DataEdit to PortEdit
//---------------------------------------------------------------------------
procedure TMain_Win.WriteButtonClick(Sender: TObject);
var
   DataPort  : Word;     // Port to read data from
   DataWrite : Longword; // Data to write to port
begin
   // Get the data port address
   try
      DataPort:=Word(StrToInt(PortEdit.Text));
   except
      MessageDlg('You have specified an invalid port.'+#13+
                 'No action performed.',
                 mtError, [mbOK], 0);
      Exit;
   end;

   // Get the data to write
   try
      DataWrite:=Longword(StrToInt(DataEdit.Text));
   except
      MessageDlg('You have specified an invalid port.'+#13+
                 'No action performed.',
                 mtError, [mbOK], 0);
      Exit;
   end;

   // Write the data
   case FDataType of
      dtByte:  DLPortIO.Port[DataPort]:=Byte(DataWrite and $FF);
      dtWord:  DLPortIO.PortW[DataPort]:=Word(DataWrite and $FFFF);
      dtDWord: DLPortIO.PortL[DataPort]:=DataWrite;
   end;
end;

//---------------------------------------------------------------------------
// ByteRadioClick()
//    Set for Byte writing
//---------------------------------------------------------------------------
procedure TMain_Win.ByteRadioClick(Sender: TObject);
begin
   FDataType:=dtByte;
end;

//---------------------------------------------------------------------------
// WordRadioClick()
//    Set for Word writing
//---------------------------------------------------------------------------
procedure TMain_Win.WordRadioClick(Sender: TObject);
begin
   FDataType:=dtWord;
end;

//---------------------------------------------------------------------------
// DWordRadioClick()
//    Set for Double Word writing
//---------------------------------------------------------------------------
procedure TMain_Win.DWordRadioClick(Sender: TObject);
begin
   FDataType:=dtDWord;
end;

//---------------------------------------------------------------------------
// AboutButtonClick()
//    Shows the about dialog box
//---------------------------------------------------------------------------
procedure TMain_Win.AboutButtonClick(Sender: TObject);
begin
   MessageDlg(
      'DriverLINX driver wrapper component Demo'+#13+
      'Copyright (c) 1999 John Pappas (DiskDude). All rights reserved.'+#13+#13+
      'See http://diskdude.cjb.net/ for the latest version.',
      mtInformation,
      [mbOK],
      0);
end;

end.
