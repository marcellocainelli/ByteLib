unit Model.Query.Firedac;

interface

uses

  System.Classes,
  System.StrUtils,
  System.SysUtils,
  System.Variants,

  Data.DB,

  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Script,
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
  TModelQueryFiredac = class(TInterfacedObject, iQuery)
    private
      FParent: iConexao;
      FDQuery: TFDQuery;
      FUpdateTransaction: TFDTransaction;
      FScript: TFDScript;
    public
      constructor Create(Parent: iConexao);
      destructor Destroy; override;
      class function New(Parent: iConexao): iQuery;
      function SQL(Value: String): iQuery;
      function Dataset: TDataSet;
      function AddParametro(NomeParametro: String; ValorParametro: Variant; DataType: TFieldType): iQuery;
      function Close: iQuery;
      function ExecQuery(Value: String): iQuery;
      function Salva(Commit: Boolean = True): iQuery;
      function ApplyUpdates: iQuery;
      function IndexFieldNames(FieldName: String): iQuery;
      function StartTransaction: iQuery;
      function InTransaction: Boolean;
      function Commit: iQuery;
      function Rollback: iQuery;
      function ChangeCount(DataSet: TDataSet): integer;
      function GetFieldNames(Table: string; List: TStrings): iQuery;
  end;

implementation

{ TModelQueryFiredac }

constructor TModelQueryFiredac.Create(Parent: iConexao);
begin
  FParent:= Parent;
  FDQuery:= TFDQuery.Create(nil);
  FUpdateTransaction:= TFDTransaction.Create(nil);

  if not Assigned(FParent) then
    FParent:= TModelConexaoFiredac.New;

  FDQuery.Connection:= TFDConnection(FParent.Connection);
  FDQuery.ResourceOptions.ParamCreate := False;
  FDQuery.CachedUpdates:= True;

  FUpdateTransaction.Connection:= TFDConnection(FParent.Connection);
  {$IFDEF SERVER}
    FDWDriverFD.Connection:= TFDConnection(FParent.Connection);
    FDWPooler.RESTDriver:= FDWDriverFD;
  {$ENDIF}
end;

function TModelQueryFiredac.Dataset: TDataSet;
begin
  Result:= FDQuery;
end;

destructor TModelQueryFiredac.Destroy;
begin
  FreeAndNil(FDQuery);
  FreeAndNil(FUpdateTransaction);
  FreeAndNil(FScript);
  inherited;
end;

class function TModelQueryFiredac.New(Parent: iConexao): iQuery;
begin
  Result:= Self.Create(Parent);
end;

function TModelQueryFiredac.SQL(Value: String): iQuery;
begin
  Result:= Self;
  FDQuery.Close;
  FDQuery.SQL.Clear;
  FDQuery.SQL.Add(Value);
  FDQuery.Active:= true;
end;

function TModelQueryFiredac.ExecQuery(Value: String): iQuery;
begin
  Result:= Self;
  FDQuery.Close;
  FDQuery.SQL.Clear;
  FDQuery.SQL.Add(Value);
  FDQuery.ExecSQL;
 end;

function TModelQueryFiredac.GetFieldNames(Table: string; List: TStrings): iQuery;
begin
  Result:= Self;
  TFDConnection(FParent.Connection).GetFieldNames('', '', Table, '', List);
end;

function TModelQueryFiredac.AddParametro(NomeParametro: String; ValorParametro: Variant; DataType: TFieldType): iQuery;
begin
  Result:= Self;
  FDQuery.Params.Add.Name:= NomeParametro;
  FDQuery.Params.ParamValues[NomeParametro]:= ValorParametro;
  FDQuery.Params.Add.DataType:= DataType;
  if DataType = ftString then
    FDQuery.Params.Add.Size:= Length(NomeParametro);
  FDQuery.Params.Add.ParamType:= ptInput;
end;

function TModelQueryFiredac.Close: iQuery;
begin
  Result:= Self;
  FDQuery.Close;
end;

//http://docwiki.embarcadero.com/RADStudio/Sydney/en/Caching_Updates_(FireDAC)
function TModelQueryFiredac.Salva(Commit: Boolean = True): iQuery;
begin
  Result:= Self;
  if not InTransaction then
    TFDConnection(FParent.Connection).StartTransaction;
  Try
    If FDQuery.ApplyUpdates(0) > 0 then
      raise exception.Create('Ocorreu um erro ao tentar gravar o registro!');
    FDQuery.CommitUpdates;
    if Commit then
      TFDConnection(FParent.Connection).Commit;
  except
    TFDConnection(FParent.Connection).Rollback;
    raise;
  end;
end;

function TModelQueryFiredac.IndexFieldNames(FieldName: String): iQuery;
begin
  Result:= Self;
  FDQuery.IndexFieldNames:= FieldName;
end;

function TModelQueryFiredac.InTransaction: Boolean;
begin
  Result:= TFDConnection(FParent.Connection).InTransaction;
end;

function TModelQueryFiredac.StartTransaction: iQuery;
begin
  Result:= Self;

  TFDConnection(FParent.Connection).StartTransaction;
end;

function TModelQueryFiredac.Commit: iQuery;
begin
  Result:= Self;

  TFDConnection(FParent.Connection).Commit;
end;

function TModelQueryFiredac.Rollback: iQuery;
begin
  Result:= Self;

  TFDConnection(FParent.Connection).Rollback;
end;

function TModelQueryFiredac.ApplyUpdates: iQuery;
begin
  try
    FDQuery.ApplyUpdates(0);
    FDQuery.CommitUpdates;
  except
    on E:Exception do
      raise Exception.Create('Ocorreu um erro ao tentar gravar o registro: ' + E.Message);
  end;
end;

function TModelQueryFiredac.ChangeCount(DataSet: TDataSet): integer;
begin
  Result:= TFDQuery(DataSet).ChangeCount;
end;

end.

