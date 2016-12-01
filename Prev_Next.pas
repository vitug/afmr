unit Prev_Next;

interface

Uses
  Windows, Messages, SysUtils, Dialogs,FileRelis;

Type
  TNextPrev= class(TObject)
    Procedure Next(F_Name: String);
    Procedure Prev(F_Name: String);
    Function P: String;
  end;

Var
  Name: TFiles;
  Val: String;
implementation

Function TNextPrev.P: String;
begin
InputQuery('AFMR folder',
           'Укажите рабочий каталог в фомате: "res:\folder1\...\"',val);
Result:=Val;
end;

Procedure TnextPrev.Next(F_Name: String);
begin
Name.F_Open(P,F_Name,'r');
if Name.Error then exit;

end;

Procedure TNextPrev.Prev(F_Name: String);
begin
end;


end.
