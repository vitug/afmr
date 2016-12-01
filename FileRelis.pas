unit FileRelis;

interface

Uses
  Windows, Messages, SysUtils, Dialogs, StrUtils,
  CommonTypes;

Type
  TMode = Char;
  DataString = String[100];

Type
  TFiles = class
  private
    FFile: text; // текстовый файл
    FFilePath: String;  //Каталог спектров
    FRootPathProgramm: String; //Корневой каталог программы
    FRootDebug: String;        //Корневой каталог отладки
    FDebugSubDir: String;      //Каталог отладки маркерующийся по дате и времени
    FRootFontsDir: String;         //Каталог шрифтов
  public
    constructor CreateDirectory;
    procedure F_Open(FileName:String; Mode: TMode);
    procedure F_Write(time: Double; value: SHORT; voltage: Double);
    procedure F_WriteStr(Str1, Str2, Str3: Variant);
    procedure CreateSubDirDebug;
    function  GetWords(S: DataString): TFileADC_Data;
    function  F_Read: String;
    function  Error: Boolean;
    function MakeFileNameWithZeros(Value: integer; Digit: integer = 8): String;
    procedure F_Close;
    property SpectrsRoot: String read FFilePath;
    property ProgrammRoot: String read FRootPathProgramm;
    property DebugRoot: String read FRootDebug;
    property DebugTimeStampDir: String read FDebugSubDir;
    property FontsRoot: String read FRootFontsDir;
  end;

implementation

function TFiles.MakeFileNameWithZeros(Value:integer; Digit:integer = 8): String;
var
  ValueS, S: String;
  i: integer;
begin
  ValueS := IntToStr(Value);
  s := '';
  for i := 0 to (Digit-1) - length(ValueS) do
    S := S + '0';
  Result := S + ValueS;
end;

Constructor TFiles.CreateDirectory;
begin
  inherited Create;
  FRootPathProgramm := GetCurrentDir + '\';
  FRootDebug := FRootPathProgramm + 'Debug\';
  FRootFontsDir := FRootPathProgramm + 'Fonts\';
  FFilePath := DateToStr(Date, FormatSettings) + '\' + TimeToStr(Time, FormatSettings);
  FFilePath := 'Data\' + FFilePath + '\';
  FFilePath := FRootPathProgramm + FFilePath;

  ForceDirectories(FFilePath);  //Создаем корневой каталог спектров
  ForceDirectories(FRootDebug); //Создаем корневой каталог для файлов отладки
end;

procedure TFiles.CreateSubDirDebug;
var
  path: String;
begin
  Path := DateToStr(Date, FormatSettings) + '\' + TimeToStr(Time, FormatSettings);
  if not DirectoryExists(FDebugSubDir) then
  begin
    FDebugSubDir := FRootDebug + Path + '\';
    ForceDirectories(FDebugSubDir); //Создаем подкаталог для файлов отладки
  end;
end;

procedure TFiles.F_Open(FileName: String; Mode: TMode);
var
  name :String;
begin
  Name := FileName + '.dat';
  AssignFile(FFile, FFilePath + Name);
{$I-}
  if UpCase('w') = UpCase(Mode) then
    Rewrite(FFile);

  if UpCase('r') = UpCase(Mode) then
    Reset(FFile);

  if UpCase('a') = UpCase(Mode) then
    Append(FFile);
{$I+}
end;

function TFiles.Error: Boolean;
begin
  if IOResult <> 0 then
    Result := True
  else
    Result := False;
end;

procedure TFiles.F_Close;
begin
  CloseFile(FFile);
end;

procedure TFiles.F_Write(time: Double; value: SHORT; voltage: Double);
begin
  WriteLn(FFile, time, ' ', value, ' ', voltage);
end;

procedure TFiles.F_WriteStr(Str1, Str2, Str3: Variant);
begin
  WriteLn(FFile, Str1, ' ', Str2, ' ', Str3);
end;

function TFiles.F_Read: String;
Var
  Data: String;
begin
  ReadLn(FFile, Data);
  F_Read := Data;
end;

function TFiles.GetWords(S: DataString): TFileADC_Data;
var
  j, i: WORD;
  D: TFileADC_Data;
begin
  j := 0;
  SetLength(D, FileDebugParam);
  for i := 1 to length(S) do
  begin
    if (S[i] = ' ') and (S[i - 1] <> ' ') then
    begin
      inc(j);
    end;
    D[j] := D[j] + s[i];
  end;
  Result := D;
end;

end.
