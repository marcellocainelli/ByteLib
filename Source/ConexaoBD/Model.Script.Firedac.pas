unit Model.Script.Firedac;
interface
uses
  System.Classes,
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Script,
  FireDAC.Comp.ScriptCommands,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Async,
  FireDAC.Stan.Error,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  Model.Conexao.Firedac,
  Model.Conexao.Interfaces;
Type
  TModelScriptFiredac = class(TInterfacedObject, iScript)
    private
      FParent: iConexao;
      FScript: TFDScript;
    public
      constructor Create(Parent: iConexao);
      destructor Destroy; override;
      class function New(Parent: iConexao): iScript;
      function Clear: iScript;
      function Add: iScript;
      function SQLAdd(AValue: String): iScript;
      function SQLSaveToFile(AValue: String): iScript;
      function ValidateAll: Boolean;
      function ExecuteAll: Boolean;
      function StartTransaction: iScript;
      function InTransaction: Boolean;
      function Commit: iScript;
      function Rollback: iScript;
      function Execute: Boolean;
      function AddScriptsFromList(AList: TStringList): iScript;
  end;
implementation
{ TModelScriptFiredac }
constructor TModelScriptFiredac.Create(Parent: iConexao);
begin
  FParent:= Parent;
  FScript:= TFDScript.Create(nil);
  if not Assigned(FParent) then
    FParent:= TModelConexaoFiredac.New;
  FScript.Connection:= TFDConnection(FParent.Connection);
  //FScript.Transaction:= FUpdateTransaction;
  FScript.ScriptOptions.IgnoreError:= False;
  FScript.ScriptOptions.BreakOnError:= True;
end;
destructor TModelScriptFiredac.Destroy;
begin
  FreeAndNil(FScript);
  inherited;
end;
class function TModelScriptFiredac.New(Parent: iConexao): iScript;
begin
  Result:= Self.Create(Parent);
end;
function TModelScriptFiredac.Add: iScript;
begin
  Result:= Self;
  FScript.SQLScripts.Add;
end;
function TModelScriptFiredac.Clear: iScript;
begin
  Result:= Self;
  FScript.SQLScripts.Clear;
end;
function TModelScriptFiredac.ExecuteAll: Boolean;
begin
  Result:= FScript.ExecuteAll;
end;
function TModelScriptFiredac.SQLAdd(AValue: String): iScript;
begin
  Result:= Self;
  FScript.SQLScripts[0].SQL.Add(AValue);
end;
function TModelScriptFiredac.SQLSaveToFile(AValue: String): iScript;
begin
  Result:= Self;
  FScript.SQLScripts[0].SQL.SaveToFile(AValue);
end;
function TModelScriptFiredac.ValidateAll: Boolean;
begin
  Result:= FScript.ValidateAll;
end;
function TModelScriptFiredac.StartTransaction: iScript;
begin
  Result:= Self;
  TFDConnection(FParent.Connection).StartTransaction;
end;
function TModelScriptFiredac.InTransaction: Boolean;
begin
  Result:= TFDConnection(FParent.Connection).InTransaction;
end;
function TModelScriptFiredac.Commit: iScript;
begin
  Result:= Self;
  TFDConnection(FParent.Connection).Commit;
end;
function TModelScriptFiredac.Rollback: iScript;
begin
  Result:= Self;
  TFDConnection(FParent.Connection).Rollback;
end;
function TModelScriptFiredac.Execute: Boolean;
begin
  Result:= False;
  try
    if FScript.ValidateAll then
      Result:= FScript.ExecuteAll;
  except
    on E:Exception do
      raise Exception.Create(E.Message);
  end;
end;
function TModelScriptFiredac.AddScriptsFromList(AList: TStringList): iScript;
begin
  Result:= Self;
  try
    FScript.SQLScripts.Clear;
    FScript.SQLScripts.Add.SQL:= AList;
  except
    on E:Exception do
      raise Exception.Create(E.Message);
  end;
end;
end.
