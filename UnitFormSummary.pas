unit UnitFormSummary;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,  StdCtrls,
  CommonTypes, Sp_unit;

type
  TFormSummary = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    EditComment: TEdit;
    GroupBoxPropExp: TGroupBox;
    ComboBoxCrystal: TComboBox;
    ComboBoxGenerator: TComboBox;
    ComboBoxSection: TComboBox;
    ComboBoxOrientation: TComboBox;
    ButtonOk: TButton;
    ComboBoxThermopair: TComboBox;
    Label6: TLabel;
    procedure FormShow(Sender: TObject);
    procedure ButtonOkClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    FSpectrometer: TSpectrometer;

    //Заполняет строки комбобоксов
    procedure FillListComboxs(ComboBox: TComboBox; Strings: TStrings);

    procedure UpdateFormData;
    procedure SetDataToSpectrometer;
    procedure SaveLastChanges;
  public
    { Public declarations }
    property Spectrometer: TSpectrometer read FSpectrometer write FSpectrometer;
  end;

var
  FormSummary: TFormSummary;

implementation

uses StrUtils;

{$R *.dfm}

procedure TFormSummary.FormShow(Sender: TObject);
begin
  Width := 540;
  Height := 300;
  
end;

//------------------------------------------------------------------

procedure TFormSummary.ButtonOkClick(Sender: TObject);
begin
  //Передадим данные спектрометру
  SetDataToSpectrometer;
  //закроем форму
  FormSummary.Close;
end;

//------------------------------------------------------------------

procedure TFormSummary.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
    close;
end;

//------------------------------------------------------------------

procedure TFormSummary.UpdateFormData;
begin
  ComboBoxCrystal.Clear;
  ComboBoxGenerator.Clear;
  ComboBoxSection.Clear;
  ComboBoxOrientation.Clear;
  ComboBoxThermopair.Clear;

  //Заполним все комбобоксы доступными значениями из файла
  FillListComboxs(ComboBoxCrystal, FSpectrometer.IniFileParam.GetCrystalList);
  FillListComboxs(ComboBoxGenerator, FSpectrometer.IniFileParam.GetGeneratorList);
  FillListComboxs(ComboBoxSection, FSpectrometer.IniFileParam.GetSectionList);
  FillListComboxs(ComboBoxThermopair, FSpectrometer.IniFileParam.GetThermopairList);
  FillListComboxs(ComboBoxOrientation, FSpectrometer.IniFileParam.GetOrientationList);

  //Покажим текущие значения из Spectrometr
  with FSpectrometer.Description do
  begin
    ComboBoxCrystal.Text := StringReplace(Crystal, '_', ' ', [rfReplaceAll, rfIgnoreCase]);
    ComboBoxGenerator.Text := StringReplace(Generator, '_', ' ', [rfReplaceAll, rfIgnoreCase]);
    ComboBoxSection.Text := StringReplace(Section, '_', ' ', [rfReplaceAll, rfIgnoreCase]);
    ComboBoxThermopair.Text := StringReplace(Thermopair, '_', ' ', [rfReplaceAll, rfIgnoreCase]);
    ComboBoxOrientation.Text := StringReplace(Orientation, '_', ' ', [rfReplaceAll, rfIgnoreCase]);
    EditComment.Text := StringReplace(Comment, '_', ' ', [rfReplaceAll, rfIgnoreCase]);
  end;
end;

//------------------------------------------------------------------

procedure TFormSummary.SetDataToSpectrometer;
begin
  //Передадим текущие значения в Spectrometr
  with FSpectrometer.Description do
  begin
    Crystal := StringReplace(ComboBoxCrystal.Text, ' ', '_', [rfReplaceAll, rfIgnoreCase]);
    Generator := StringReplace(ComboBoxGenerator.Text, ' ', '_', [rfReplaceAll, rfIgnoreCase]);
    Section := StringReplace(ComboBoxSection.Text, ' ', '_', [rfReplaceAll, rfIgnoreCase]);
    Thermopair := StringReplace(ComboBoxThermopair.Text, ' ', '_', [rfReplaceAll, rfIgnoreCase]);
    Orientation := StringReplace(ComboBoxOrientation.Text, ' ', '_', [rfReplaceAll, rfIgnoreCase]);
    Comment := StringReplace(EditComment.Text, ' ', '_', [rfReplaceAll, rfIgnoreCase]);
  end;

  //сохраним последние значения
  SaveLastChanges;
end;

//------------------------------------------------------------------

procedure TFormSummary.FormActivate(Sender: TObject);
begin
// Обновим данные на форме
  UpdateFormData;
end;

//------------------------------------------------------------------

procedure TFormSummary.FillListComboxs(ComboBox: TComboBox; Strings: TStrings);
var
  i: integer;
begin
  for i := 0 to Strings.Count - 1 do
    ComboBox.Items.Add(RightStr(Strings[i], Length(Strings[i]) - Pos('=', Strings[i])));
end;

//------------------------------------------------------------------

procedure TFormSummary.SaveLastChanges;
var
  LastChanges: TLastChangesExperiment;
begin
// Сохраним в файле выбранные значения, чтобы восстановить их при след запуске
  with LastChanges do
  begin
    Crystal := Fspectrometer.Description.Crystal;
    Generator := Fspectrometer.Description.Generator;
    Section := Fspectrometer.Description.Section;
    Thermopair := Fspectrometer.Description.Thermopair;
    Orientation := Fspectrometer.Description.Orientation;
    Comment := Fspectrometer.Description.Comment;
  end;
  FSpectrometer.IniFileParam.SetLastChangesExperiment(LastChanges);
end;

end.
