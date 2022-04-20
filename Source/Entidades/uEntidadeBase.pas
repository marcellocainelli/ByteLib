unit uEntidadeBase;
interface
uses
  System.SysUtils,
  uDmFuncoes,
  Controller.Factory.Query,
  Data.DB,
  Model.Conexao.Interfaces,
  Model.Entidade.Interfaces;
Type
  TEntidadeBase<T: IInterface> = class(TInterfacedObject, iEntidadeBase<T>)
  private
    [Weak]
    FParent: T;
    FQuery: iQuery;
    FTextoSql: String;
    FTextoPesquisa: String;
    FTipoPesquisa: Integer;
    FRegraPesquisa: String;
    FInativos: boolean;
    FDataSource: TDataSource;
  public
    constructor Create(Parent: T);
    destructor Destroy; override;
    class function New(Parent: T): iEntidadeBase<T>;
    function Salva(Value: TDataSource = nil): iEntidadeBase<T>;
    function Exclui(Value: TDataSource = nil): iEntidadeBase<T>;
    function AddParametro(NomeParametro: String; ValorParametro: Variant; DataType: TFieldType): iEntidadeBase<T>;
    function RefreshDataSource(Value: TDataSource = nil): iEntidadeBase<T>;
    function SaveIfChangeCount(DataSource: TDataSource = nil): iEntidadeBase<T>;
    function InsertBeforePost(DataSource: TDataSource = nil; AEvent: TDataSetNotifyEvent = nil): iEntidadeBase<T>;
    function Validate(Value: TDataSource = nil; ANomeCampo: string = ''; AEvent: TFieldNotifyEvent = nil): iEntidadeBase<T>;
    function SetReadOnly(Value: TDataSource = nil; ANomeCampo: string = ''; AReadOnly: boolean = false): iEntidadeBase<T>;
    function CalcFields(AEvent: TDatasetNotifyEvent): iEntidadeBase<T>;
    function CriaCampo(ADataSource: TDataSource = nil; ANomeCampo: string = ''; ADataType: TFieldType = ftUnknown): iEntidadeBase<T>;
    function &End : T;

    function TextoSQL(pValue: String): String; overload;
    function TextoSQL: String; overload;
    function TextoPesquisa(pValue: String): String; overload;
    function TextoPesquisa: String; overload;
    function TipoPesquisa(pValue: Integer ): Integer; overload;
    function TipoPesquisa: Integer ; overload;
    function RegraPesquisa(pValue: String): String; overload;
    function RegraPesquisa: String; overload;
    function Inativos(pValue: boolean): boolean; overload;
    function Inativos: boolean; overload;
    function Iquery: iQuery; overload;
  end;

implementation

{ TEntidadeBase<T> }

constructor TEntidadeBase<T>.Create(Parent: T);
begin
  FParent:= Parent;
  FQuery:= TControllerFactoryQuery.New.Query(DmFuncoes.Connection);
  FDataSource:= TDataSource.Create(nil);
end;

destructor TEntidadeBase<T>.Destroy;
begin
  inherited;
  FreeAndNil(FDataSource);
end;

class function TEntidadeBase<T>.New(Parent: T): iEntidadeBase<T>;
begin
  Result:= Self.Create(Parent);
end;

function TEntidadeBase<T>.Salva(Value: TDataSource): iEntidadeBase<T>;
begin
  Result:= Self;
  if Value = nil then
    Value:= FDataSource;
  Try
    FQuery.Salva;
    //Value.DataSet.Refresh;
  Except
    on E: Exception do begin
      Value.DataSet.Edit;
      raise Exception.Create('Não foi possível salvar. Erro:' + E.Message);
    end;
  End;
end;

function TEntidadeBase<T>.Exclui(Value: TDataSource): iEntidadeBase<T>;
begin
  Result:= Self;
  if Value = nil then
    Value:= FDataSource;
  Try
    Value.DataSet.Delete;
    FQuery.Salva;
  Except
    on E: Exception do begin
      raise Exception.Create('Não foi possível excluir. Erro:' + E.Message);
    end;
  End;
end;

function TEntidadeBase<T>.AddParametro(NomeParametro: String; ValorParametro: Variant; DataType: TFieldType): iEntidadeBase<T>;
begin
  FQuery.AddParametro(NomeParametro, ValorParametro, DataType);
end;

function TEntidadeBase<T>.RefreshDataSource(Value: TDataSource): iEntidadeBase<T>;
begin
  Result:= Self;
  if Value = nil then
    Value:= FDataSource;
  Value.DataSet.Close;
  Value.DataSet.Open;
end;

function TEntidadeBase<T>.SaveIfChangeCount(DataSource: TDataSource): iEntidadeBase<T>;
begin
  Result:= Self;
  if DataSource = nil then
    DataSource:= FDataSource;
  if FQuery.ChangeCount(DataSource.DataSet) > 0 then
    Salva(DataSource);
end;

function TEntidadeBase<T>.SetReadOnly(Value: TDataSource; ANomeCampo: string; AReadOnly: boolean): iEntidadeBase<T>;
begin
  Result:= Self;
  if Value = nil then
    Value:= FDataSource;
  Value.DataSet.FieldByName(ANomeCampo).ReadOnly:= AReadOnly;
end;

function TEntidadeBase<T>.CalcFields(AEvent: TDatasetNotifyEvent): iEntidadeBase<T>;
begin
  Result:= Self;
  FQuery.CalcFields(AEvent);
end;

function TEntidadeBase<T>.CriaCampo(ADataSource: TDataSource; ANomeCampo: string; ADataType: TFieldType): iEntidadeBase<T>;
var
  vField: TField;
  i: integer;
begin
  if ADataSource = nil then
    ADataSource:= FDataSource;
  ADataSource.DataSet.Close;
  ADataSource.Dataset.FieldDefs.Updated:= false;
  ADataSource.Dataset.FieldDefs.Update;
  for i := 0 to ADataSource.Dataset.FieldDefs.Count - 1 do
    ADataSource.Dataset.FieldDefs[i].CreateField(nil);
  case ADataType of
    ftBoolean : vField:= TBooleanField.Create(ADataSource.Dataset);
    ftCurrency: vField:= TCurrencyField.Create(ADataSource.Dataset);
  end;
  vField.FieldName:= ANomeCampo;
  vField.FieldKind:= fkInternalCalc;
  vField.DataSet:= ADataSource.Dataset;
end;

function TEntidadeBase<T>.&End: T;
begin
  Result:= FParent;
end;

function TEntidadeBase<T>.Inativos: boolean;
begin
  Result:= FInativos;
end;

function TEntidadeBase<T>.InsertBeforePost(DataSource: TDataSource; AEvent: TDataSetNotifyEvent): iEntidadeBase<T>;
begin
  if DataSource = nil then
    DataSource:= FDataSource;
  DataSource.DataSet.BeforePost:= AEvent;
end;

function TEntidadeBase<T>.Validate(Value: TDataSource; ANomeCampo: string; AEvent: TFieldNotifyEvent): iEntidadeBase<T>;
begin
  if Value = nil then
    Value:= FDataSource;
  Value.DataSet.FieldByName(ANomeCampo).OnValidate:= AEvent;
end;

function TEntidadeBase<T>.Inativos(pValue: boolean): boolean;
begin
  Result:= True;
  FInativos:= pValue;
end;

function TEntidadeBase<T>.RegraPesquisa: String;
begin
  Result:= FRegraPesquisa;
end;

function TEntidadeBase<T>.RegraPesquisa(pValue: String): String;
begin
  Result:= EmptyStr;
  FRegraPesquisa:= pValue;
end;

function TEntidadeBase<T>.TextoPesquisa: String;
begin
  Result:= FTextoPesquisa;
end;

function TEntidadeBase<T>.TextoSQL: String;
begin
  Result:= FTextoSQL;
end;

function TEntidadeBase<T>.TextoSQL(pValue: String): String;
begin
  Result:= EmptyStr;
  FTextoSQL:= pValue;
end;

function TEntidadeBase<T>.TextoPesquisa(pValue: String): String;
begin
  Result:= EmptyStr;
  FTextoPesquisa:= pValue;
end;

function TEntidadeBase<T>.TipoPesquisa: Integer;
begin
  Result:= FTipoPesquisa;
end;

function TEntidadeBase<T>.TipoPesquisa(pValue: Integer): Integer;
begin
  Result:= 0;
  FTipoPesquisa:= pValue;
end;

function TEntidadeBase<T>.Iquery: iQuery;
begin
  Result:= FQuery;
end;

end.
