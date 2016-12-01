//*** TDLPortIO: DriverLINX Port IO Driver wrapper component *****************
//**                                                                        **
//** File: PortIO.pas                                                       **
//**                                                                        **
//** Copyright (c) 1999 John Pappas (DiskDude). All rights reserved.        **
//**     This software is FreeWare                                          **
//**                                                                        **
//**     Please notify me if you make any changes to this file.             **
//**     Email: diskdude@poboxes.com                                        **
//**                                                                        **
//**                                                                        **
//** The following resources helped in developing the install, start, stop  **
//** and remove code for dynamically opening/closing the DriverLINX WinNT   **
//** kernel mode driver.                                                    **
//**                                                                        **
//**   "Dynamically Loading Drivers in Windows NT" by Paula Tomlinson       **
//**   from "Windows Developer's Journal", Volume 6, Issue 5. (C code)      **
//**      ftp://ftp.mfi.com/pub/windev/1995/may95.zip                       **
//**                                                                        **
//**   "Hardware I/O Port Programming with Delphi and NT" by Graham Wideman **
//**      http://www.wideman-one.com/tech/Delphi/IOPM/index.htm             **
//**                                                                        **
//**                                                                        **
//** Special thanks to Peter Holm <comtext3@post4.tele.dk> for his          **
//** algorithm and code for detecting the number and addresses of the       **
//** installed printer ports, on which the detection code below is based.   **
//**                                                                        **
//*** http://diskdude.cjb.net/ ***********************************************

unit PortIO;

interface

uses
  Windows, Messages, SysUtils, Classes, WinSvc;

//---------------------------------------------------------------------------
// DLL Import Types
//    Pointer to functions, to dynamically link into the DLL
//---------------------------------------------------------------------------

type
   PByte = ^Byte;
   PWord = ^Word;
   PLongword = ^Longword;

type
   TDlPortReadPortUchar = function(Port : Word) : Byte; stdcall;
   TDlPortReadPortUshort = function(Port : Word) : Word; stdcall;
   TDlPortReadPortUlong =  function(Port : Word) : Longword; stdcall;

   TDlPortWritePortUchar = procedure(Port : Word; Value : Byte); stdcall;
   TDlPortWritePortUshort = procedure(Port : Word; Value : Word); stdcall;
   TDlPortWritePortUlong = procedure(Port : Word; Value : Longword); stdcall;

   TDlPortReadPortBufferUchar = procedure(Port : Word; Buffer : PByte; Count : Longword); stdcall;
   TDlPortReadPortBufferUshort = procedure(Port : Word; Buffer : PWord; Count : Longword); stdcall;
   TDlPortReadPortBufferUlong = procedure(Port : Word; Buffer : PLongword; Count : Longword); stdcall;

   TDlPortWritePortBufferUchar = procedure(Port : Word; Buffer : PByte; Count : Longword); stdcall;
   TDlPortWritePortBufferUshort = procedure(Port : Word; Buffer : PWord; Count : Longword); stdcall;
   TDlPortWritePortBufferUlong = procedure(Port : Word; Buffer : PLongword; Count : Longword); stdcall;

//---------------------------------------------------------------------------
// Data Types
//---------------------------------------------------------------------------

// Specifies the type of read or write in a TPortCommand
type
   TMode = (tmReadByte, tmReadWord, tmReadDWord,
            tmWriteByte, tmWriteWord, tmWriteDWord);

// Specifies the data required to do a block
// read/write of an array of port records.
// Extends the model TVicHW32/TVicPort uses
type
   TPortCommand = record
      PortAddr : Word;     // The address of the port to read/write
      PortData : Longword; // The data to read/write
                           // If a byte, only lower 8bits are used, or 16bits
                           // if reading/writing a word
      PortMode : TMode;    // The mode of reading/writing
   end;

// Standard TVicHW32/TVicPort PortRec for compatibility
type
   TPortRec = record
      PortAddr : Word;    // Address
      PortData : Byte;    // Data (for writing or after reading)
      fWrite   : Boolean; // TRUE if you want to write this port
                          // and FALSE if to read.
   end;


//---------------------------------------------------------------------------
// TDLPortIO class
//    This is supposed to be compatible with TVicPort
//---------------------------------------------------------------------------

type
  TDLPortIO = class(TComponent)
  private
    FActiveHW : Boolean;      // Is the DLL loaded?
    FHardAccess : Boolean;    // Not used: for compatibility only
    FRunningWinNT : Boolean;  // True when we're running Windows NT

    FDLLInst : THandle;       // For use with DLL
    hSCMan : SC_HANDLE;       // For use with WinNT Service Control Manager

    FDriverPath : AnsiString; // Full path of WinNT driver
    FDLLPath : AnsiString;    // Full path of DriverLINX DLL
    FLastError : AnsiString;  // Last error which occurred in Open/CloseDriver()

    // Used for the Windows NT version only
    FDrvPrevInst : Boolean;   // DriverLINX driver already installed?
    FDrvPrevStart : Boolean;  // DriverLINX driver already running?

    // Pointers to the functions within the DLL
    DlReadByte : TDlPortReadPortUchar;
    DlReadWord : TDlPortReadPortUshort;
    DlReadDWord : TDlPortReadPortUlong;

    DlWriteByte : TDlPortWritePortUchar;
    DlWriteWord : TDlPortWritePortUshort;
    DlWriteDWord : TDlPortWritePortUlong;

    DlReadBufferByte : TDlPortReadPortBufferUchar;
    DlReadBufferWord : TDlPortReadPortBufferUshort;
    DlReadBufferDWord : TDlPortReadPortBufferUlong;

    DlWriteBufferByte : TDlPortWritePortBufferUchar;
    DlWriteBufferWord : TDlPortWritePortBufferUshort;
    DlWriteBufferDWord : TDlPortWritePortBufferUlong;

    // Connects and disconnects to the WinNT Service Control Manager
    function ConnectSCM : Boolean;
    procedure DisconnectSCM;

    // Installs, starts, stops and removes the WinNT kernel mode driver
    function DriverInstall : Boolean;
    function DriverStart : Boolean;
    function DriverStop : Boolean;
    function DriverRemove : Boolean;

  protected
    // returns true if the DLL/Driver is loaded
    function IsLoaded : Boolean;

    // Wrappers for the properties below
    function GetPortByte(Address : Word) : Byte;
    procedure SetPortByte(Address : Word; Data : Byte);
    function GetPortWord(Address : Word) : Word;
    procedure SetPortWord(Address : Word; Data : Word);
    function GetPortDWord(Address : Word) : Longword;
    procedure SetPortDWord(Address : Word; Data : Longword);

  public
    constructor Create(Owner : TComponent); override;
    destructor Destroy; override;

    // These open and close the DLL/Driver
    procedure OpenDriver;
    procedure CloseDriver;

    // Allows write/read array of ports.
    procedure PortControl(Ports : array of TPortRec; NumPorts : Word);
    procedure PortCommand(Ports : array of TPortCommand; NumPorts : Word);

    // Allows read/write array of bytes from single port.
    procedure ReadPortFIFO(PortAddr : Word; NumPorts : Word; var Buffer);
    procedure WritePortFIFO(PortAddr : Word; NumPorts : Word; var Buffer);

    // Extended block read/write routines for WORD and DWORD
    procedure ReadWPortFIFO(PortAddr : Word; NumPorts : Word; var Buffer);
    procedure WriteWPortFIFO(PortAddr : Word; NumPorts : Word; var Buffer);
    procedure ReadLPortFIFO(PortAddr : Word; NumPorts : Word; var Buffer);
    procedure WriteLPortFIFO(PortAddr : Word; NumPorts : Word; var Buffer);

    // Access any port as you like, similar to the old pascal way of doing things
    property Port[Address : Word] : Byte read GetPortByte write SetPortByte;
    property PortW[Address : Word] : Word read GetPortWord write SetPortWord;
    property PortL[Address : Word] : Longword read GetPortDWord write SetPortDWord;

  published
    // Sets the path (no ending \, nor any filename) of the DLPortIO.SYS file
    // Assumed to be <windows system directory>\DRIVERS if not specified
    property DriverPath : AnsiString read FDriverPath write FDriverPath;

    // Sets the path (no ending \, nor any filename) of the DLPortIO.DLL file
    // Assumed to be "" if not specified, meaning it will search the program
    // path, windows directory and computer's path for the DLL
    property DLLPath : AnsiString read FDLLPath write FDLLPath;

    // True when the DLL/Driver has been loaded successfully after OpenDriver()
    property ActiveHW : Boolean read FActiveHW;
    // This doesn't really do anything; provided for compatibility only
    property HardAccess : Boolean read FHardAccess write FHardAccess default true;

    // Returns the last error which occurred in Open/CloseDriver()
    property LastError : AnsiString read FLastError;
  end;


//---------------------------------------------------------------------------
// Types for the TDLPrinterPortIO class
//---------------------------------------------------------------------------

type
   TPinNumber = 1..25;

//---------------------------------------------------------------------------
// TDLPrinterPortIO class
//    This is supposed to be compatible with TVicLPT
//---------------------------------------------------------------------------

const
   // Maximum number of printer ports
   // that would be installed on a system
   MAX_LPT_PORTS = 8;

type
  TDLPrinterPortIO = class(TDLPortIO)
    private
       FLPTNumber : Byte;    // Current number of the printer port, default=1
       FLPTBase : Word;      // The address of the current printer port (faster)

       FLPTCount : Integer;  // Number of LPT ports on the system

       // List of port addresses installed on the system
       FLPTAddress : array[0..MAX_LPT_PORTS] of Word;

       // Detects the printer ports using the registry
       procedure DetectPorts;
       procedure DetectPorts9x; // Win9x version
       procedure DetectPortsNT; // WinNT version

    protected
       function GetLPTNumPorts : Byte;
       function GetLPTBasePort : Word;
       procedure SetLPTNumber(Number : Byte);

       function GetPin(Index : TPinNumber) : Boolean;
       procedure SetPin(Index : TPinNumber; State : Boolean);

       function GetLPTAckwl : Boolean;
       function GetLPTBusy : Boolean;
       function GetLPTPaperEnd : Boolean;
       function GetLPTSlct : Boolean;
       function GetLPTError : Boolean;

    public
       constructor Create(Owner : TComponent); override;

       // Sends STROBE signal to the printer
       procedure LPTStrobe;
       // Sends AUTOFD (auto line feed) signal to the printer
       procedure LPTAutofd(Flag : Boolean);
       // Resets printer by sending INIT signal
       procedure LPTInit;
       // Sends SLCTIN signal to the printer
       procedure LPTSlctIn;
       // Sends a character to the printer.
       // Returns true on success. Repeat as neccessary.
       function LPTPrintChar(Ch : Char) : Boolean;

       // Index valid is in the range 1-25 only (other values return false)
       // Reading the pin returns true when it is 5V, or false when it at 0V.
       // Writing true sets the pin to 5V, or 0V when false.
       property Pin[Index : TPinNumber] : Boolean read GetPin write SetPin;

       // Returns ACKWL state from the printer
       property LPTAckwl : Boolean read GetLPTAckwl;
       // Returns BUSY state from the printer
       property LPTBusy : Boolean read GetLPTBusy;
       // Returns PAPER END state from the printer
       property LPTPaperEnd : Boolean read GetLPTPaperEnd;
       // Returns SLCT state from the printer
       property LPTSlct : Boolean read GetLPTSlct;
       // Returns ERROR state from the printer
       property LPTError : Boolean read GetLPTError;

    published
       // Shows how many LPT ports are installed on your PC.
       property LPTNumPorts : Byte read GetLPTNumPorts;
       // Selects the LPT port to use for all LPT operations
       property LPTNumber : Byte read FLPTNumber write SetLPTNumber default 1;
       // Returns a base address of the current LPT port.
       property LPTBasePort : Word read GetLPTBasePort;
  end;

procedure Register;

implementation

//---------------------------------------------------------------------------
// Constants
//---------------------------------------------------------------------------

const
   // Masks
   BIT0 : Byte = $01;
   BIT1 : Byte = $02;
   BIT2 : Byte = $04;
   BIT3 : Byte = $08;
   BIT4 : Byte = $10;
   BIT5 : Byte = $20;
   BIT6 : Byte = $40;
   BIT7 : Byte = $80;

   // Printer Port pin numbers
   ACK_PIN       : Byte = 10;
   BUSY_PIN      : Byte = 11;
   PAPEREND_PIN  : Byte = 12;
   SELECTOUT_PIN : Byte = 13;
   ERROR_PIN     : Byte = 15;
   STROBE_PIN    : Byte = 1;
   AUTOFD_PIN    : Byte = 14;
   INIT_PIN      : Byte = 16;
   SELECTIN_PIN  : Byte = 17;

   // DriverLINX DLL filename
   LIBRARY_FILENAME : AnsiString = 'DLPortIO.dll';

   // WinNT DriverLINX Information
   DRIVER_NAME      : AnsiString = 'DLPortIO';
   DISPLAY_NAME     : AnsiString = 'DriverLINX Port I/O Driver';
   DRIVER_GROUP     : AnsiString = 'SST miniport drivers';


//---------------------------------------------------------------------------
constructor TDLPortIO.Create(Owner : TComponent);
//---------------------------------------------------------------------------
var
   os     : TOSVERSIONINFO;
   Buffer : array[1..MAX_PATH] of char;
begin
   inherited Create(Owner); // Set up our inherited methods, and properties

   // Are we running Windows NT?
   os.dwPlatformId := 0;
   os.dwOSVersionInfoSize := sizeof(OSVERSIONINFO);
   GetVersionEx(os);
   FRunningWinNT:=(os.dwPlatformId=VER_PLATFORM_WIN32_NT);

   // Set default WinNT driver path
   GetSystemDirectory(@Buffer, MAX_PATH);
   FDriverPath:=Buffer+'\DRIVERS';

   // Set the default DLL path
   FDLLPath:='';

   FActiveHW:=false;  // DLL/Driver not loaded
   FHardAccess:=true; // Not used, default true

   FLastError:='';    // No errors yet
end;

//---------------------------------------------------------------------------
destructor TDLPortIO.Destroy;
//---------------------------------------------------------------------------
begin
   // Make sure we close the DLL
   if (IsLoaded) then CloseDriver;

   inherited Destroy; // Destroy out inherited methods, and properties
end;

//---------------------------------------------------------------------------
// Connects to the WinNT Service Control Manager
function TDLPortIO.ConnectSCM : Boolean;
//---------------------------------------------------------------------------
const
   SC_MANAGER_CONNECT           = $0001;
   SC_MANAGER_QUERY_LOCK_STATUS = $0010;
   SC_MANAGER_ENUMERATE_SERVICE = $0004;
   SC_MANAGER_CREATE_SERVICE    = $0002;

   ERROR_ACCESS_DENIED          = $0005;
var
   dwStatus : DWORD;
   scAccess : DWORD;
begin
   dwStatus := 0;           // Assume success, until we prove otherwise

   // Try and connect as administrator
   scAccess := SC_MANAGER_CONNECT or
               SC_MANAGER_QUERY_LOCK_STATUS or
               SC_MANAGER_ENUMERATE_SERVICE or
               SC_MANAGER_CREATE_SERVICE;      // Admin only

   // Connect to the SCM
   hSCMan := OpenSCManager(nil, nil, scAccess);

   // If we're not in administrator mode, try and reconnect
   if ((hSCMan=0) and (GetLastError=ERROR_ACCESS_DENIED)) then
   begin
      scAccess := SC_MANAGER_CONNECT or
                  SC_MANAGER_QUERY_LOCK_STATUS or
                  SC_MANAGER_ENUMERATE_SERVICE;

      // Connect to the SCM
      hSCMan := OpenSCManager(nil, nil, scAccess);
   end;

   // Did it succeed?
   if (hSCMan=0) then
   begin
      // Failed, save error information
      dwStatus:=GetLastError;
      FLastError:='ConnectSCM: Error #'+IntToStr(dwStatus);
   end;

   Result := (dwStatus=0); // Success == 0
end;

//---------------------------------------------------------------------------
// Disconnects from the WinNT Service Control Manager
procedure TDLPortIO.DisconnectSCM;
//---------------------------------------------------------------------------
begin
   if (hSCMan<>0) then
   begin
      // Disconnect from our local Service Control Manager
      CloseServiceHandle(hSCMan);
      hSCMan:=0;
   end;
end;

//---------------------------------------------------------------------------
// Installs, starts, stops and removes the WinNT kernel mode driver
function TDLPortIO.DriverInstall : Boolean;
//---------------------------------------------------------------------------
const
   SERVICE_KERNEL_DRIVER  = $00001;
   SERVICE_DEMAND_START   = $00003;
   SERVICE_ERROR_NORMAL   = $00001;
   SERVICE_START          = $00010;
   SERVICE_STOP           = $00020;
   SERVICE_QUERY_STATUS   = $00004;
   DELETE                 = $10000;
var
   hService : SC_HANDLE;    // Handle to the new service
   dwStatus : DWORD;
   DriverPath : AnsiString; // Path including filename
Begin
   dwStatus := 0;           // Assume success, until we prove otherwise

   FDrvPrevInst := false;   // Assume the driver wasn't installed previously

   // Path including filename
   DriverPath := FDriverPath+'\'+DRIVER_NAME+'.SYS';

   // Is the DriverLINX driver already in the SCM? If so,
   // indicate success and set FDrvPrevInst to true.
   hService:=OpenService(hSCMan, PChar(DRIVER_NAME), SERVICE_QUERY_STATUS);
   if (hService<>0) then
   begin
      FDrvPrevInst := true;         // Driver previously installed, don't remove
      CloseServiceHandle(hService); // Close the service
      Result := true;               // Success
      Exit;
   end;

   // Add to our Service Control Manager's database
   hService:=CreateService(
                hSCMan,
                PChar(DRIVER_NAME),
                PChar(DISPLAY_NAME),
                SERVICE_START or SERVICE_STOP or DELETE or SERVICE_QUERY_STATUS,
                SERVICE_KERNEL_DRIVER,
                SERVICE_DEMAND_START,
                SERVICE_ERROR_NORMAL,
                PChar(DriverPath),
                PChar(DRIVER_GROUP),
                nil, nil, nil, nil);

   if (hService=0) then
      // Get the error that occurred
      dwStatus := GetLastError
   else
      // Close the service for now...
      CloseServiceHandle(hService);

   if (dwStatus<>0) then
      FLastError:='DriverInstall: Error #'+IntToStr(dwStatus);

   Result := (dwStatus=0); // Success == 0
end;

//---------------------------------------------------------------------------
function TDLPortIO.DriverStart : Boolean;
//---------------------------------------------------------------------------
const
   SERVICE_START          = $00010;
   SERVICE_QUERY_STATUS   = $00004;
   SERVICE_RUNNING        = $00004;
   SERVICE_STOPPED        = $00001;
var
   hService            : SC_HANDLE;    // Handle to the new service
   dwStatus            : DWORD;
   lpServiceArgVectors : PChar;
   sStatus             : TServiceStatus;
Begin
   dwStatus := 0;          // Assume success, until we prove otherwise

   FDrvPrevStart := false; // Assume the driver was not already running

   hService := OpenService(hSCMan, PChar(DRIVER_NAME), SERVICE_QUERY_STATUS);
   if ((hService<>0) and (QueryServiceStatus(hService, sStatus))) then
   begin
      // Got the service status, now check it
      if (sStatus.dwCurrentState=SERVICE_RUNNING) then
      begin
         FDrvPrevStart:=true;          // Driver was previously started
         CloseServiceHandle(hService); // Close service
         Result := true;               // Success
         Exit;
      end
      else if (sStatus.dwCurrentState=SERVICE_STOPPED) then
      begin
         // Driver was stopped. Start the driver.
         CloseServiceHandle(hService);
         hService := OpenService(hSCMan, PChar(DRIVER_NAME), SERVICE_START);
         if (not StartService(hService, 0, lpServiceArgVectors)) then
            dwStatus:=GetLastError;
         CloseServiceHandle(hService); // Close service
      end
      else dwStatus:=$FFFFFFFF; // Can't run the service
   end
   else
      dwStatus:=GetLastError;

   if (dwStatus<>0) then
      FLastError:='DriverStart: Error #'+IntToStr(dwStatus);

   Result := (dwStatus=0); // Success == 0
end;

//---------------------------------------------------------------------------
function TDLPortIO.DriverStop : Boolean;
//---------------------------------------------------------------------------
const
   SERVICE_QUERY_STATUS   = $00004;
   SERVICE_STOP           = $00020;
   SERVICE_CONTROL_STOP   = $00001;
var
   hService      : SC_HANDLE;    // Handle to the new service
   dwStatus      : DWORD;
   Temp          : LongBool;
   ServiceStatus : TServiceStatus;
begin
   dwStatus := 0; // Assume success, until we prove otherwise

   // If we didn't start the driver, then don't stop it.
   // Pretend we stopped it, by indicating success.
   if (FDrvPrevStart) then
   begin
      Result := true;
      Exit;
   end;

   // Get a handle to the service to stop
   hService := OpenService(
                  hSCMan,
                  PChar(DRIVER_NAME),
                  SERVICE_STOP or SERVICE_QUERY_STATUS);

   if (hService<>0) then
   begin
      // Stop the driver, then close the service
      Temp := ControlService(hService, SERVICE_CONTROL_STOP, ServiceStatus);
      if (not Temp) then
         dwStatus := GetLastError();

      // Close the service
      CloseServiceHandle(hService);
   end else
      dwStatus := GetLastError;

   if (dwStatus<>0) then
      FLastError:='DriverStop: Error #'+IntToStr(dwStatus);

   Result := (dwStatus=0); // Success == 0
end;

//---------------------------------------------------------------------------
function TDLPortIO.DriverRemove : Boolean;
//---------------------------------------------------------------------------
const
   DELETE                 = $10000;
var
   hService      : SC_HANDLE;    // Handle to the new service
   dwStatus      : DWORD;
   Temp          : LongBool;
begin
   dwStatus := 0; // Assume success, until we prove otherwise

   // If we didn't install the driver, then don't remove it.
   // Pretend we removed it, by indicating success.
   if (FDrvPrevInst) then
   begin
      Result := true;
      Exit;
   end;

   // Get a handle to the service to stop
   hService := OpenService(
                  hSCMan,
                  PChar(DRIVER_NAME),
                  DELETE);

   if (hService<>0) then
   begin
      // Remove the driver then close the service again
      Temp := DeleteService(hService);
      if (not Temp) then
         dwStatus := GetLastError;

      // Close the service
      CloseServiceHandle(hService);
   end else
      dwStatus := GetLastError;

   if (dwStatus<>0) then
      FLastError:='DriverRemove: Error #'+IntToStr(dwStatus);

   Result := (dwStatus=0); // Success == 0
end;

//---------------------------------------------------------------------------
// returns true if the DLL/Driver is loaded
function TDLPortIO.IsLoaded : Boolean;
//---------------------------------------------------------------------------
begin
   Result := FActiveHW;
end;

//---------------------------------------------------------------------------
function TDLPortIO.GetPortByte(Address : Word) : Byte;
//---------------------------------------------------------------------------
begin
   Result := DlReadByte(Address);
end;

//---------------------------------------------------------------------------
procedure TDLPortIO.SetPortByte(Address : Word; Data : Byte);
//---------------------------------------------------------------------------
begin
   DlWriteByte(Address, Data);
end;

//---------------------------------------------------------------------------
function TDLPortIO.GetPortWord(Address : Word) : Word;
//---------------------------------------------------------------------------
begin
   Result := DlReadWord(Address);
end;

//---------------------------------------------------------------------------
procedure TDLPortIO.SetPortWord(Address : Word; Data : Word);
//---------------------------------------------------------------------------
begin
   DlWriteWord(Address, Data);
end;

//---------------------------------------------------------------------------
function TDLPortIO.GetPortDWord(Address : Word) : Longword;
//---------------------------------------------------------------------------
begin
   Result := DlReadDWord(Address);
end;

//---------------------------------------------------------------------------
procedure TDLPortIO.SetPortDWord(Address : Word; Data : Longword);
//---------------------------------------------------------------------------
begin
   DlWriteDWord(Address, Data);
end;

//---------------------------------------------------------------------------
procedure TDLPortIO.OpenDriver;
//---------------------------------------------------------------------------
var
   LibraryFileName : AnsiString;
begin
   // If the DLL/driver is already open, then forget it!
   if (IsLoaded) then Exit;

   // If we're running Windows NT, install the driver then start it
   if (FRunningWinNT) then
   begin
      // Connect to the Service Control Manager
      if (not ConnectSCM) then Exit;

      // Install the driver
      if (not DriverInstall) then
      begin
         // Driver install failed, so disconnect from the SCM
         DisconnectSCM;
         Exit;
      end;

      // Start the driver
      if (not DriverStart) then
      begin
         // Driver start failed, so remove it then disconnect from SCM
         DriverRemove;
         DisconnectSCM;
         Exit;
      end;
   end;

   // Load DLL library
   LibraryFileName := LIBRARY_FILENAME;

   if (FDLLPath<>'') then
      LibraryFileName := FDLLPath+'\'+LIBRARY_FILENAME;

   FDLLInst:=LoadLibrary(PChar(LibraryFileName));
   if (FDLLInst<>0) then
   begin
      @DlReadByte:=GetProcAddress(FDLLInst,'DlPortReadPortUchar');
      @DlReadWord:=GetProcAddress(FDLLInst,'DlPortReadPortUshort');
      @DlReadDWord:=GetProcAddress(FDLLInst,'DlPortReadPortUlong');

      @DlWriteByte:=GetProcAddress(FDLLInst,'DlPortWritePortUchar');
      @DlWriteWord:=GetProcAddress(FDLLInst,'DlPortWritePortUshort');
      @DlWriteDWord:=GetProcAddress(FDLLInst,'DlPortWritePortUlong');

      @DlReadBufferByte:=GetProcAddress(FDLLInst,'DlPortReadPortBufferUchar');
      @DlReadBufferWord:=GetProcAddress(FDLLInst,'DlPortReadPortBufferUshort');
      @DlReadBufferDWord:=GetProcAddress(FDLLInst,'DlPortReadPortBufferUlong');

      @DlWriteBufferByte:=GetProcAddress(FDLLInst,'DlPortWritePortBufferUchar');
      @DlWriteBufferWord:=GetProcAddress(FDLLInst,'DlPortWritePortBufferUshort');
      @DlWriteBufferDWord:=GetProcAddress(FDLLInst,'DlPortWritePortBufferUlong');

      // Make sure all our functions are there
      if ((@DlReadByte<>nil) and (@DlReadWord<>nil) and
          (@DlReadDWord<>nil) and (@DlWriteByte<>nil) and
          (@DlWriteWord<>nil) and (@DlWriteDWord<>nil) and
          (@DlReadBufferByte<>nil) and (@DlReadBufferWord<>nil) and
          (@DlReadBufferDWord<>nil) and (@DlWriteBufferByte<>nil) and
          (@DlWriteBufferWord<>nil) and (@DlWriteBufferDWord<>nil)) then
         FActiveHW:=true; // Success
   end;

   // Did we fail?
   if (not FActiveHW) then
   begin
      // If we're running Windows NT, stop the driver then remove it
      // Forget about any return (error) values we might get...
      if (FRunningWinNT) then
      begin
         DriverStop;
         DriverRemove;
         DisconnectSCM;
      end;

      // Free the library
      if (FDLLInst<>0) then
      begin
         FreeLibrary(FDLLInst);
         FDLLInst:=0;
      end;
   end;
end;

//---------------------------------------------------------------------------
procedure TDLPortIO.CloseDriver;
//---------------------------------------------------------------------------
begin
   // Don't close anything if it wasn't opened previously
   if (not IsLoaded) then Exit;

   // If we're running Windows NT, stop the driver then remove it
   if (FRunningWinNT) then
   begin
      if (not DriverStop) then Exit;
      if (not DriverRemove) then Exit;
      DisconnectSCM;
   end;

   // Free the library
   if (not FreeLibrary(FDLLInst)) then Exit;
   FDLLInst:=0;

   FActiveHW:=false; // Success
end;

//---------------------------------------------------------------------------
procedure TDLPortIO.PortControl(Ports : array of TPortRec; NumPorts : Word);
//---------------------------------------------------------------------------
var
   Index : Word;
begin
   for Index := 1 to NumPorts do
      if (Ports[Index].fWrite) then
         DlWriteByte(Ports[Index].PortAddr, Ports[Index].PortData)
      else
         Ports[Index].PortData:=DlReadByte(Ports[Index].PortAddr);
end;

//---------------------------------------------------------------------------
procedure TDLPortIO.PortCommand(Ports : array of TPortCommand; NumPorts : Word);
//---------------------------------------------------------------------------
var
   Index : Word;
begin
   for Index := 1 to NumPorts do
      case (Ports[Index].PortMode) of
         tmReadByte:
            Ports[Index].PortData:=DlReadByte(Ports[Index].PortAddr);
         tmReadWord:
            Ports[Index].PortData:=DlReadWord(Ports[Index].PortAddr);
         tmReadDWord:
            Ports[Index].PortData:=DlReadDWord(Ports[Index].PortAddr);
         tmWriteByte:
            DlWriteByte(Ports[Index].PortAddr, Ports[Index].PortData);
         tmWriteWord:
            DlWriteWord(Ports[Index].PortAddr, Ports[Index].PortData);
         tmWriteDWord:
            DlWriteDWord(Ports[Index].PortAddr, Ports[Index].PortData);
      end;
end;

//---------------------------------------------------------------------------
procedure TDLPortIO.ReadPortFIFO(PortAddr : Word; NumPorts : Word; var Buffer);
//---------------------------------------------------------------------------
begin
   DlReadBufferByte(PortAddr, @Buffer, NumPorts);
end;

//---------------------------------------------------------------------------
procedure TDLPortIO.WritePortFIFO(PortAddr : Word; NumPorts : Word; var Buffer);
//---------------------------------------------------------------------------
begin
   DlWriteBufferByte(PortAddr, @Buffer, NumPorts);
end;

//---------------------------------------------------------------------------
procedure TDLPortIO.ReadWPortFIFO(PortAddr : Word; NumPorts : Word; var Buffer);
//---------------------------------------------------------------------------
begin
   DlReadBufferWord(PortAddr, @Buffer, NumPorts);
end;

//---------------------------------------------------------------------------
procedure TDLPortIO.WriteWPortFIFO(PortAddr : Word; NumPorts : Word; var Buffer);
//---------------------------------------------------------------------------
begin
   DlWriteBufferWord(PortAddr, @Buffer, NumPorts);
end;

//---------------------------------------------------------------------------
procedure TDLPortIO.ReadLPortFIFO(PortAddr : Word; NumPorts : Word; var Buffer);
//---------------------------------------------------------------------------
begin
   DlReadBufferDWord(PortAddr, @Buffer, NumPorts);
end;

//---------------------------------------------------------------------------
procedure TDLPortIO.WriteLPortFIFO(PortAddr : Word; NumPorts : Word; var Buffer);
//---------------------------------------------------------------------------
begin
   DlWriteBufferDWord(PortAddr, @Buffer, NumPorts);
end;


//---------------------------------------------------------------------------
constructor TDLPrinterPortIO.Create(Owner : TComponent);
//---------------------------------------------------------------------------
begin
   inherited Create(Owner); // Set up our inherited methods, and properties

   FLPTNumber := 0;   // No LPT selected
   FLPTBase := 0;     // No base address
   FLPTCount := 0;    // No printer ports counted

   DetectPorts();     // Detect the printer ports available

   SetLPTNumber(1);         // Default LPT number
end;

//---------------------------------------------------------------------------
procedure TDLPrinterPortIO.DetectPorts;
//---------------------------------------------------------------------------
var
   RunningWinNT : Boolean;
   os : TOSVersionInfo;
begin
   // Are we running Windows NT?
   os.dwPlatformId := 0;
   os.dwOSVersionInfoSize := sizeof(os);
   GetVersionEx(os);
   RunningWinNT:=(os.dwPlatformId=VER_PLATFORM_WIN32_NT);

   // Detect the printer ports available
   if (RunningWinNT) then
      DetectPortsNT()  // WinNT version
   else
      DetectPorts9x(); // Win9x version
end;

//---------------------------------------------------------------------------
procedure TDLPrinterPortIO.DetectPorts9x;
//---------------------------------------------------------------------------
const
   BASE_KEY     : AnsiString = 'Config Manager\Enum';
   PROBLEM      : AnsiString = 'Problem';
   ALLOCATION   : AnsiString = 'Allocation';
   PORT_NAME    : AnsiString = 'PortName';
   HARDWARE_KEY : AnsiString = 'HardwareKey';

   KEY_PERMISSIONS : REGSAM = KEY_ENUMERATE_SUB_KEYS or KEY_QUERY_VALUE;

var
   CurKey   : HKEY;            // Current key when using the registry
   KeyName  : AnsiString;      // A key name when using the registry

   KeyList  : TStringList;     // List of keys
   KeyIndex : DWord;           // For loop variable
   KeyCount : DWord;           // Count of the number of keys in KeyList

   index    : DWord;           // Index for 'for' loops

   DummyFileTime  : TFileTime;
   DummyLength    : DWord;
   DummyString    : array[0..MAX_PATH] of char;

   HasProblem     : Boolean;   // Does a port entry have any problems?
   DataType,
   DataSize       : DWord;     // Type and Size of data in the registry

   // Data from "Problem" sub-key
   ProblemData    : array[0..63] of Byte;

   PortName       : AnsiString; // Name of a port
   PortNumber     : Integer;    // The number of a port

   // Holds the registry data for the port address allocation
   PortAllocation : array[0..63] of Word;

begin
   // Clear the port count
   FLPTCount := 0;

   // Clear the port array
   for index :=0 to MAX_LPT_PORTS do
      FLPTAddress[index] := 0;

   // Open the registry
   RegOpenKeyEx(HKEY_DYN_DATA, PChar(BASE_KEY), 0, KEY_PERMISSIONS, CurKey);

   // Grab all the key names under HKEY_DYN_DATA
   KeyList := TStringList.create;
   DummyLength := MAX_PATH;
   KeyCount := 0;
   while (RegEnumKeyEx(
            CurKey, KeyCount, @DummyString, DummyLength,
            nil, nil, nil, @DummyFileTime
                       ) <> ERROR_NO_MORE_ITEMS) do
   begin
      KeyList.Add(DummyString);
      DummyLength := MAX_PATH;
      inc(KeyCount);
   end;

   // Close the key
   RegCloseKey(CurKey);

   // Cycle through all keys; looking for a string valued subkey called
   // 'HardWareKey' which is not nil, and another subkey called 'Problem'
   // whose fields are all valued 0.
   for KeyIndex :=0 to KeyCount-1 do
   begin
      HasProblem := false; // Is 'Problem' non-zero? Assume it is Ok

      // Open the key
      KeyName := BASE_KEY + '\' + KeyList.Strings[KeyIndex];
      if (RegOpenKeyEx(
            HKEY_DYN_DATA, PChar(KeyName), 0, KEY_PERMISSIONS, CurKey
                        ) <> ERROR_SUCCESS) then
         Continue;

      // Test for a 0 valued Problem sub-key,
      // which must only consist of raw data
      RegQueryValueEx(CurKey, PChar(PROBLEM), nil, @DataType, nil, @DataSize);
      if (DataType = REG_BINARY) then
      begin
         // We have a valid, binary "Problem" sub-key
         // Test to see if the fields are zero

         // Read the data from the "Problem" sub-key
         if (RegQueryValueEx(
                  CurKey, PChar(PROBLEM), nil,
                  nil, @ProblemData, @DataSize
                             ) = ERROR_SUCCESS) then
         begin
            // See if it has any problems
            for index :=0 to DataSize-1 do
               if ProblemData[index] <> 0 then
                  HasProblem := true;
         end
         else
            HasProblem := true; // No good

         // Now try and read the Hardware sub-key
         DataSize := MAX_PATH;
         RegQueryValueEx(
            CurKey, PChar(HARDWARE_KEY), nil, @DataType, @DummyString, @DataSize
                         );
         if (DataType <> REG_SZ) then
            HasProblem := true; // No good

         // Do we have no problem, and a non-nil Hardware sub-key?
         if ((not HasProblem) and (StrLen(DummyString) > 0)) then
         begin
            // Now open the key which is "pointed at" by HardwareSubKey
            RegCloseKey(CurKey);

            KeyName := 'Enum\'+DummyString;
            if (RegOpenKeyEx(
                  HKEY_LOCAL_MACHINE, PChar(KeyName), 0, KEY_PERMISSIONS, CurKey
                              ) <> ERROR_SUCCESS) then
               Continue;

            // Now read in the PortName and obtain the LPT number from it
            DataSize := MAX_PATH;
            RegQueryValueEx(
               CurKey, PChar(PORT_NAME), nil, @DataType, @DummyString, @DataSize
                            );
            PortName := DummyString;
            if (DataType <> REG_SZ) then
               PortName := ''; // No good

            // Make sure it has LPT in it
            if (StrPos(PChar(PortName), 'LPT') <> nil) then
            begin
               for index:=0 to MAX_PATH do
                  DummyString[index] := #0;

               StrLCopy(DummyString,
                        StrPos(PChar(PortName), 'LPT') + 3,
                        StrLen(PChar(PortName))
                           - (StrPos(PChar(PortName), 'LPT')
                           - @PortName) - 2
                        );

               // Find the port number
               try
                  PortNumber := StrToInt(DummyString);
               except
                  PortNumber := 0;
               end;

               // Find the address
               RegCloseKey(CurKey);

               KeyName := BASE_KEY + '\' + KeyList.Strings[KeyIndex];
               RegOpenKeyEx(HKEY_DYN_DATA, PChar(KeyName), 0, KEY_PERMISSIONS, CurKey);

               DataSize := sizeof(PortAllocation);
               RegQueryValueEx(
                  CurKey, PChar(ALLOCATION), nil, @DataType,
                  @PortAllocation, @DataSize
                               );
               if (DataType = REG_BINARY) then
               begin
                  // Decode the Allocation data: the port address is present
                  // directly after a 0x000C entry (which doesn't have 0x0000
                  // after it).
                  for index := 0 to 63 do
                     if ((PortAllocation[index] = $000C) and
                         (PortAllocation[index+1] <> $0000) and
                         (PortNumber<=MAX_LPT_PORTS)) then
                     begin
                        // Found a port; add it to the list
                        FLPTAddress[PortNumber] := PortAllocation[index+1];
                        inc(FLPTCount);
                        Break;
                     end;

               end;

            end;

         end;
      end;

      RegCloseKey(CurKey);
   end;

   // Destroy our key list
   KeyList.Free;
end;

//---------------------------------------------------------------------------
procedure TDLPrinterPortIO.DetectPortsNT;
//---------------------------------------------------------------------------
const
   BASE_KEY        : AnsiString = 'HARDWARE\DEVICEMAP\PARALLEL PORTS';
   LOADED_KEY      : AnsiString = 'HARDWARE\RESOURCEMAP\LOADED PARALLEL DRIVER RESOURCES\Parport';
   DOS_DEVICES     : AnsiString = '\DosDevices\LPT';
   DEVICE_PARALLEL : AnsiString = '\Device\Parallel';

   KEY_PERMISSIONS : REGSAM = KEY_ENUMERATE_SUB_KEYS or KEY_QUERY_VALUE;

var
   CurKey     : HKEY;            // Current key when using the registry
   KeyName    : AnsiString;      // A key name when using the registry

   ValueList  : TStringList;     // List of Value names
   ValueIndex : DWord;           // For loop variable
   ValueCount : DWord;           // Count of the number of items in KeyList

   index      : DWord;           // Index for 'for' loops

   DummyLength    : DWord;
   DummyString    : array[0..MAX_PATH] of char;

   // Key value for \DosDevices\LPT
   DosDev         : array[0..MAX_PATH] of char;

   DataType,
   DataSize       : DWord;      // Type and Size of data in the registry

   PortNumber     : Integer;    // The number of a port

   // Holds the registry data for the port address allocation
   PortAllocation : array[0..63] of Word;

begin
   // Clear the port count
   FLPTCount := 0;

   // Clear the port array
   for index :=0 to MAX_LPT_PORTS do
      FLPTAddress[index] := 0;


   // Open the registry
   if (RegOpenKeyEx(
         HKEY_LOCAL_MACHINE, PChar(BASE_KEY), 0, KEY_PERMISSIONS, CurKey
                     ) <> ERROR_SUCCESS) then
      exit; // Can't do anything without this BASE_KEY

   // Grab all the value names under HKEY_LOCAL_MACHINE

   ValueList := TStringList.create;

   ValueCount := 0;
   DummyLength := MAX_PATH;
   while (RegEnumValue(
            CurKey, ValueCount, DummyString, DummyLength,
            nil, @DataType, nil, nil
                       ) <> ERROR_NO_MORE_ITEMS) do
   begin
      ValueList.Add(DummyString);
      DummyLength := MAX_PATH;
      inc(ValueCount);
   end;

   // Close the key
   RegCloseKey(CurKey);

   for ValueIndex :=0 to ValueCount-1 do
   begin
      // Is it a \DosDevices\LPT key?
      KeyName := BASE_KEY;
      if (RegOpenKeyEx(
            HKEY_LOCAL_MACHINE, PChar(KeyName), 0, KEY_PERMISSIONS, CurKey
                        ) = ERROR_SUCCESS) then
      begin
         DataSize := MAX_PATH;
         RegQueryValueEx(
            CurKey, PChar(ValueList.Strings[ValueIndex]), nil,
            @DataType, @DosDev, @DataSize
                         );
         RegCloseKey(CurKey);

         // Make sure it was a string
         if (DataType <> REG_SZ) then
            DosDev := '';
      end
      else
         DosDev := '';

      if (StrPos(DosDev, PChar(DOS_DEVICES)) <> nil) then
      begin
         // Get the port number
         for index:=0 to MAX_PATH do
            DummyString[index] := #0;

         StrLCopy(DummyString,
                  StrPos(DosDev, PChar(DOS_DEVICES))
                     + StrLen(PChar(DOS_DEVICES)),
                  StrLen(DosDev)
                     - (StrPos(DosDev, PChar(DOS_DEVICES)) - @DosDev)
                     - StrLen(PChar(DOS_DEVICES)) + 1
                  );
         try
            PortNumber := StrToInt(DummyString);
         except
            PortNumber := 0;
         end;

         // Get the Port ID
         for index:=0 to MAX_PATH do
            DummyString[index] := #0;

         StrLCopy(DummyString,
                  StrPos(PChar(ValueList.Strings[ValueIndex]), PChar(DEVICE_PARALLEL))
                     + StrLen(PChar(DEVICE_PARALLEL)),
                  StrLen(PChar(ValueList.Strings[ValueIndex]))
                     - (StrPos(
                           PChar(ValueList.Strings[ValueIndex]),
                           PChar(DEVICE_PARALLEL)
                               )
                        - PChar(ValueList.Strings[ValueIndex]))
                     - StrLen(PChar(DEVICE_PARALLEL)) + 1
                  );

         // Get the port address
         RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar(LOADED_KEY), 0, KEY_PERMISSIONS, CurKey);

         StrCopy(DosDev, PChar('\Device\ParallelPort' + DummyString + '.Raw'));

         if ((RegQueryValueEx(
                CurKey, DosDev, nil, @DataType, nil, nil
                              ) = ERROR_SUCCESS) and
             (DataType = REG_RESOURCE_LIST)) then
         begin
            // Read in the binary data
            DataSize := sizeof(PortAllocation);
            RegQueryValueEx(
               CurKey, @DosDev, nil, nil,
               @PortAllocation, @DataSize
                            );

            // Found a port; add it to the list
            if ((DataSize>0) and (PortNumber<=MAX_LPT_PORTS)) then
            begin
               FLPTAddress[PortNumber] := PortAllocation[12];
               inc(FLPTCount);
            end;
         end;

         RegCloseKey(CurKey);
      end;
   end;

   // Destroy our value list
   ValueList.Free;
end;

//---------------------------------------------------------------------------
function TDLPrinterPortIO.GetLPTNumPorts : Byte;
//---------------------------------------------------------------------------
begin
   Result := FLPTCount;
end;

//---------------------------------------------------------------------------
function TDLPrinterPortIO.GetLPTBasePort : Word;
//---------------------------------------------------------------------------
begin
   Result := FLPTBase;
end;

//---------------------------------------------------------------------------
procedure TDLPrinterPortIO.SetLPTNumber(Number : Byte);
//---------------------------------------------------------------------------
begin
   // Note that we don't make sure it is within the range 1..FLPTCount
   // because there _might_ (can someone claify this?) be a port numbered
   // as #2, where it may be the _only_ port installed on the system.
   if ((Number>0) and (Number<=MAX_LPT_PORTS)) then
   begin
      FLPTNumber:=Number;
      FLPTBase:=FLPTAddress[Number];
   end;
end;

//---------------------------------------------------------------------------
function TDLPrinterPortIO.GetPin(Index : TPinNumber) : Boolean;
//---------------------------------------------------------------------------
begin
   case Index of
      1:  Result := (Port[FLPTBase+2] and BIT0)=0; // Inverted
      2:  Result := (Port[FLPTBase] and BIT0)<>0;
      3:  Result := (Port[FLPTBase] and BIT1)<>0;
      4:  Result := (Port[FLPTBase] and BIT2)<>0;
      5:  Result := (Port[FLPTBase] and BIT3)<>0;
      6:  Result := (Port[FLPTBase] and BIT4)<>0;
      7:  Result := (Port[FLPTBase] and BIT5)<>0;
      8:  Result := (Port[FLPTBase] and BIT6)<>0;
      9:  Result := (Port[FLPTBase] and BIT7)<>0;
      10: Result := (Port[FLPTBase+1] and BIT6)<>0;
      11: Result := (Port[FLPTBase+1] and BIT7)=0; // Inverted
      12: Result := (Port[FLPTBase+1] and BIT5)<>0;
      13: Result := (Port[FLPTBase+1] and BIT4)<>0;
      14: Result := (Port[FLPTBase+2] and BIT1)=0; // Inverted
      15: Result := (Port[FLPTBase+1] and BIT3)<>0;
      16: Result := (Port[FLPTBase+2] and BIT2)<>0;
      17: Result := (Port[FLPTBase+2] and BIT3)=0; // Inverted
   else
          Result := false; // pins 18-25 (GND), and other invalid pins
   end;
end;

//---------------------------------------------------------------------------
procedure TDLPrinterPortIO.SetPin(Index : TPinNumber; State : Boolean);
//---------------------------------------------------------------------------
begin
   if (State) then
   begin
      case Index of
         1:  Port[FLPTBase+2] := Port[FLPTBase+2] and (not BIT0);  // Inverted
         2:  Port[FLPTBase] := Port[FLPTBase] or BIT0;
         3:  Port[FLPTBase] := Port[FLPTBase] or BIT1;
         4:  Port[FLPTBase] := Port[FLPTBase] or BIT2;
         5:  Port[FLPTBase] := Port[FLPTBase] or BIT3;
         6:  Port[FLPTBase] := Port[FLPTBase] or BIT4;
         7:  Port[FLPTBase] := Port[FLPTBase] or BIT5;
         8:  Port[FLPTBase] := Port[FLPTBase] or BIT6;
         9:  Port[FLPTBase] := Port[FLPTBase] or BIT7;
         (*
         10: Port[FLPTBase+1] := Port[FLPTBase+1] or BIT6;
         11: Port[FLPTBase+1] := Port[FLPTBase+1] and (not BIT7);  // Inverted
         12: Port[FLPTBase+1] := Port[FLPTBase+1] or BIT5;
         13: Port[FLPTBase+1] := Port[FLPTBase+1] or BIT4;
         *)
         14: Port[FLPTBase+2] := Port[FLPTBase+2] and (not BIT1);  // Inverted
         (*
         15: Port[FLPTBase+1] := Port[FLPTBase+1] or BIT3;
         *)
         16: Port[FLPTBase+2] := Port[FLPTBase+2] or BIT2;
         17: Port[FLPTBase+2] := Port[FLPTBase+2] and (not BIT3);  // Inverted
      else
         // pins 18-25 (GND), and other invalid pins
      end
   end else
   begin
      case Index of
         1:  Port[FLPTBase+2] := Port[FLPTBase+2] or BIT0;    // Inverted
         2:  Port[FLPTBase] := Port[FLPTBase] and (not BIT0);
         3:  Port[FLPTBase] := Port[FLPTBase] and (not BIT1);
         4:  Port[FLPTBase] := Port[FLPTBase] and (not BIT2);
         5:  Port[FLPTBase] := Port[FLPTBase] and (not BIT3);
         6:  Port[FLPTBase] := Port[FLPTBase] and (not BIT4);
         7:  Port[FLPTBase] := Port[FLPTBase] and (not BIT5);
         8:  Port[FLPTBase] := Port[FLPTBase] and (not BIT6);
         9:  Port[FLPTBase] := Port[FLPTBase] and (not BIT7);
         (*
         10: Port[FLPTBase+1] := Port[FLPTBase+1] and (not BIT6);
         11: Port[FLPTBase+1] := Port[FLPTBase+1] or BIT7;    // Inverted
         12: Port[FLPTBase+1] := Port[FLPTBase+1] and (not BIT5);
         13: Port[FLPTBase+1] := Port[FLPTBase+1] and (not BIT4);
         *)
         14: Port[FLPTBase+2] := Port[FLPTBase+2] or BIT1;    // Inverted
         (*
         15: Port[FLPTBase+1] := Port[FLPTBase+1] and (not BIT3);
         *)
         16: Port[FLPTBase+2] := Port[FLPTBase+2] and (not BIT2);
         17: Port[FLPTBase+2] := Port[FLPTBase+2] or BIT3;    // Inverted
      else
         // pins 18-25 (GND), and other invalid pins
      end
   end;
end;

//---------------------------------------------------------------------------
function TDLPrinterPortIO.GetLPTAckwl : Boolean;
//---------------------------------------------------------------------------
begin
   Result := GetPin(ACK_PIN);
end;

//---------------------------------------------------------------------------
function TDLPrinterPortIO.GetLPTBusy : Boolean;
//---------------------------------------------------------------------------
begin
   Result := GetPin(BUSY_PIN);
end;

//---------------------------------------------------------------------------
function TDLPrinterPortIO.GetLPTPaperEnd : Boolean;
//---------------------------------------------------------------------------
begin
   Result := GetPin(PAPEREND_PIN);
end;

//---------------------------------------------------------------------------
function TDLPrinterPortIO.GetLPTSlct : Boolean;
//---------------------------------------------------------------------------
begin
   Result := GetPin(SELECTOUT_PIN);
end;

//---------------------------------------------------------------------------
function TDLPrinterPortIO.GetLPTError : Boolean;
//---------------------------------------------------------------------------
begin
   Result := GetPin(ERROR_PIN);
end;

//---------------------------------------------------------------------------
procedure TDLPrinterPortIO.LPTStrobe;
//---------------------------------------------------------------------------
begin
   // Set to strobe pin to 0V
   SetPin(STROBE_PIN, false);
   // Wait one millisecond
   Sleep(1);
   // Set strobe pin back to 5V
   SetPin(STROBE_PIN, true);
end;

//---------------------------------------------------------------------------
procedure TDLPrinterPortIO.LPTAutofd(Flag : Boolean);
//---------------------------------------------------------------------------
begin
   // Set the auto line feed pin
   SetPin(AUTOFD_PIN, Flag);
end;

//---------------------------------------------------------------------------
procedure TDLPrinterPortIO.LPTInit;
//---------------------------------------------------------------------------
begin
   // Set pin to a 0V
   SetPin(INIT_PIN, false);
   // Wait 1 ms
   Sleep(1);
   // Set pin back to 5V
   SetPin(INIT_PIN, true);
end;

//---------------------------------------------------------------------------
procedure TDLPrinterPortIO.LPTSlctIn;
//---------------------------------------------------------------------------
begin
   // Send the signal (0V)
   SetPin(SELECTIN_PIN, false);
end;

//---------------------------------------------------------------------------
function TDLPrinterPortIO.LPTPrintChar(Ch : Char) : Boolean;
//---------------------------------------------------------------------------
begin
    // Write data to Base+0
    Port[FLPTBase]:=Byte(Ch);
    // Write 0Dh to Base+2.
    Port[FLPTBase+2]:=$0D;
    // Make sure there's a delay of at least one microsecond
    Sleep(1);
    // Write 0Ch to Base+2.
    Port[FLPTBase+2]:=$0C;
    // Input from Base+1 and check if Bit 7 is 1.
    // Return this status as whether the character was printed
    Result := ((Port[FLPTBase+1] and BIT7)<>0);
end;


procedure Register;
begin
  RegisterComponents('DiskDude', [TDLPortIO, TDLPrinterPortIO]);
end;

end.
