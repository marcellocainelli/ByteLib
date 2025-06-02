unit uEntidadeBase;
interface
uses
  System.SysUtils,
  uDmConn,
  Controller.Factory.Query,
  Data.DB,
  Model.Conexao.Interfaces,
  Model.Entidade.Interfaces, Controller.Factory.Connection, System.Classes;
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
    FTipoConsulta: string;
    FInativos: boolean;
    FDataSource: TDataSource;
    FPag_Rows, FPagina: integer;
  public
    constructor Create(Parent: T; AConn: iConexao = nil);
    destructor Destroy; override;
    class function New(Parent: T; AConn: iConexao = nil): iEntidadeBase<T>;
    function Salva(Value: TDataSource = nil; aSalva: Boolean = True): iEntidadeBase<T>;
    function Exclui(Value: TDataSource = nil): iEntidadeBase<T>;
    function AddParametro(NomeParametro: String; ValorParametro: Variant; DataType: TFieldType): iEntidadeBase<T>; overload;
    function AddParametro(NomeParametro: String; ValorParametro: integer): iEntidadeBase<T>; overload;
    function AddParametro(NomeParametro: String; ValorParametro: Variant; DataType: TFieldType; FilePath: String): iEntidadeBase<T>; overload;
    function AddParametro(NomeParametro: String; DataType: TFieldType; Stream: TStream): iEntidadeBase<T>; overload;
    function RefreshDataSource(Value: TDataSource = nil): iEntidadeBase<T>;
    function SaveIfChangeCount(DataSource: TDataSource = nil): iEntidadeBase<T>;
    function InsertBeforePost(DataSource: TDataSource = nil; AEvent: TDataSetNotifyEvent = nil): iEntidadeBase<T>;
    function InsertAfterPost(DataSource: TDataSource = nil; AEvent: TDataSetNotifyEvent = nil): iEntidadeBase<T>;
    function InsertAfterEditEvent(DataSource: TDataSource = nil; AEvent: TDataSetNotifyEvent = nil): iEntidadeBase<T>;
    function Validate(Value: TDataSource = nil; ANomeCampo: string = ''; AEvent: TFieldNotifyEvent = nil): iEntidadeBase<T>;
    function SetReadOnly(Value: TDataSource = nil; ANomeCampo: string = ''; AReadOnly: boolean = false): iEntidadeBase<T>;
    function CalcFields(AEvent: TDatasetNotifyEvent): iEntidadeBase<T>;
    function CriaCampo(ADataSource: TDataSource = nil; ANomeCampo: string = ''; ADataType: TFieldType = ftUnknown): iEntidadeBase<T>; overload;
    function CriaCampo(ADataSource: TDataSource; ANomeCampo: array of string; ADataType: array of TFieldType): iEntidadeBase<T>; overload;
    function ClearDataset(Value: TDataSource): iEntidadeBase<T>;
    function InsertNewRecordEvent(AEvent: TDataSetNotifyEvent = nil): iEntidadeBase<T>;
    function FetchOptions(AMode: String = ''; ARowSetSize: integer = 0): iEntidadeBase<T>;
    function Paginacao(APagina, ARows: integer): iEntidadeBase<T>; overload;
    function Paginacao: iEntidadeBase<T>; overload;
    function &End : T;
    function TextoSQL(pValue: String): String; overload;
    function TextoSQL: String; overload;
    function TextoPesquisa(pValue: String): String; overload;
    function TextoPesquisa: String; overload;
    function TipoPesquisa(pValue: Integer ): Integer; overload;
    function TipoPesquisa: Integer ; overload;
    function RegraPesquisa(pValue: String): String; overload;
    function RegraPesquisa: String; overload;
    function TipoConsulta(pValue: String ): iEntidadeBase<T>; overload;
    function TipoConsulta: String ; overload;
    function Inativos(pValue: boolean): boolean; overload;
    function Inativos: boolean; overload;
    function Iquery: iQuery; overload;
    function DataSource: TDataSource; overload;
    procedure Pagina(AValue: integer); overload;
    function Pagina: integer; overload;
    procedure Pag_Rows(AValue: integer); overload;
    function Pag_Rows: integer; overload;
  end;
implementation
{ TEntidadeBase<T> }
constructor TEntidadeBase<T>.Create(Parent: T; AConn: iConexao);
begin
  FParent:= Parent;
  if not Assigned(AConn) then begin
    if Assigned(dmConn.Connection) then
      AConn:= dmConn.Connection
    else
      AConn:= TControllerFactoryConn.New.Conn(FDConn);
  end;
  FQuery:= TControllerFactoryQuery.New.Query(AConn);
  FDataSource:= TDataSource.Create(nil);
  FTipoConsulta:= 'Consulta';
end;
destructor TEntidadeBase<T>.Destroy;
begin
  inherited;
  FreeAndNil(FDataSource);
end;
class function TEntidadeBase<T>.New(Parent: T; AConn: iConexao): iEntidadeBase<T>;
begin
  Result:= Self.Create(Parent, AConn);
end;
function TEntidadeBase<T>.Salva(Value: TDataSource = nil; aSalva: Boolean = True): iEntidadeBase<T>;
begin
  Result:= Self;
  if Value = nil then
    Value:= FDataSource;
  Try
    FQuery.Salva(aSalva);
  Except
    on E: Exception do begin
      Value.DataSet.Edit;
      raise Exception.Create('Nao foi possivel salvar. Erro:' + E.Message);
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
      raise Exception.Create('Nao foi possivel excluir. Erro:' + E.Message);
    end;
  End;
end;
function TEntidadeBase<T>.FetchOptions(AMode: String; ARowSetSize: integer): iEntidadeBase<T>;
begin
  Result:= Self;
  FQuery.FetchOptions(AMode, ARowSetSize);
end;
function TEntidadeBase<T>.AddParametro(NomeParametro: String; ValorParametro: Variant; DataType: TFieldType): iEntidadeBase<T>;
begin
  Result:= Self;
  FQuery.AddParametro(NomeParametro, ValorParametro, DataType);
end;
function TEntidadeBase<T>.AddParametro(NomeParametro: String; ValorParametro: integer): iEntidadeBase<T>;
begin
  Result:= Self;
  FQuery.AddParametro(NomeParametro, ValorParametro);
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
function TEntidadeBase<T>.AddParametro(NomeParametro: String; ValorParametro: Variant; DataType: TFieldType; FilePath: String): iEntidadeBase<T>;
begin
  Result:= Self;
  FQuery.AddParametro(NomeParametro, ValorParametro, DataType, FilePath);
end;

function TEntidadeBase<T>.AddParametro(NomeParametro: String; DataType: TFieldType; Stream: TStream): iEntidadeBase<T>;
begin
  Result:= Self;
  FQuery.AddParametro(NomeParametro, DataType, Stream);
end;

function TEntidadeBase<T>.CalcFields(AEvent: TDatasetNotifyEvent): iEntidadeBase<T>;
begin
  Result:= Self;
  FQuery.CalcFields(AEvent);
end;
function TEntidadeBase<T>.ClearDataset(Value: TDataSource): iEntidadeBase<T>;
begin
  Result:= Self;
  if Value = nil then
    Value:= FDataSource;
  FQuery.ClearDataset(Value.Dataset);
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
    ftInteger : vField:= TIntegerField.Create(ADataSource.Dataset);
    ftCurrency: vField:= TCurrencyField.Create(ADataSource.Dataset);
    ftString  : vField:= TStringField.Create(ADataSource.Dataset);
    ftFloat   : vField:= TFloatField.Create(ADataSource.Dataset);
  end;
  vField.FieldName:= ANomeCampo;
  vField.FieldKind:= fkInternalCalc;
  vField.DataSet:= ADataSource.Dataset;
end;
function TEntidadeBase<T>.CriaCampo(ADataSource: TDataSource; ANomeCampo: array of string; ADataType: array of TFieldType): iEntidadeBase<T>;
var
  vField: TField;
  i, j: integer;
begin
  ADataSource.DataSet.Close;
  ADataSource.Dataset.FieldDefs.Updated:= false;
  ADataSource.Dataset.FieldDefs.Update;
  for i := 0 to ADataSource.Dataset.FieldDefs.Count - 1 do
    ADataSource.Dataset.FieldDefs[i].CreateField(nil);
  For j:= Low(ANomeCampo) to High(ANomeCampo) do begin
    case ADataType[j] of
      ftBoolean : vField:= TBooleanField.Create(ADataSource.Dataset);
      ftInteger : vField:= TIntegerField.Create(ADataSource.Dataset);
      ftCurrency: vField:= TCurrencyField.Create(ADataSource.Dataset);
      ftString  : vField:= TStringField.Create(ADataSource.Dataset);
      ftFloat   : vField:= TFloatField.Create(ADataSource.Dataset);
    end;
    vField.FieldName:= ANomeCampo[j];
    vField.FieldKind:= fkInternalCalc;
    vField.DataSet:= ADataSource.Dataset;
  end;
end;
function TEntidadeBase<T>.&End: T;
begin
  Result:= FParent;
end;
function TEntidadeBase<T>.Inativos: boolean;
begin
  Result:= FInativos;
end;
function TEntidadeBase<T>.InsertAfterEditEvent(DataSource: TDataSource; AEvent: TDataSetNotifyEvent): iEntidadeBase<T>;
begin
  Result:= Self;
  if DataSource = nil then
    DataSource:= FDataSource;
  DataSource.DataSet.AfterEdit:= AEvent;
end;
function TEntidadeBase<T>.InsertAfterPost(DataSource: TDataSource; AEvent: TDataSetNotifyEvent): iEntidadeBase<T>;
begin
  Result:= Self;
  if DataSource = nil then
    DataSource:= FDataSource;
  DataSource.DataSet.AfterPost:= AEvent;
end;
function TEntidadeBase<T>.InsertBeforePost(DataSource: TDataSource; AEvent: TDataSetNotifyEvent): iEntidadeBase<T>;
begin
  Result:= Self;
  if DataSource = nil then
    DataSource:= FDataSource;
  DataSource.DataSet.BeforePost:= AEvent;
end;
function TEntidadeBase<T>.InsertNewRecordEvent(AEvent: TDataSetNotifyEvent): iEntidadeBase<T>;
begin
  Result:= Self;
  FQuery.InsertNewRecordEvent(AEvent);
end;
function TEntidadeBase<T>.Validate(Value: TDataSource; ANomeCampo: string; AEvent: TFieldNotifyEvent): iEntidadeBase<T>;
begin
  Result:= Self;
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
function TEntidadeBase<T>.TipoConsulta: String;
begin
  Result:= FTipoConsulta;
end;
function TEntidadeBase<T>.TipoConsulta(pValue: String): iEntidadeBase<T>;
begin
  Result:= Self;
  FTipoConsulta:= pValue;
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
function TEntidadeBase<T>.DataSource: TDataSource;
begin
  Result:= FDataSource;
end;
function TEntidadeBase<T>.Paginacao: iEntidadeBase<T>;
begin
  Result:= Self;
  if (FPagina > 0) and (FPag_Rows > 0) then
    FQuery.SQL_Add(Format(' ROWS %d TO %d', [FPagina, FPag_Rows]));
end;
function TEntidadeBase<T>.Paginacao(APagina, ARows: integer): iEntidadeBase<T>;
begin
  Result:= Self;
  if APagina > 0 then begin
    if APagina = 1 then begin
      FPagina:= APagina;
      FPag_Rows:= ARows;
    end else begin
      FPagina:= ((ARows * (APagina - 1)) + 1);
      FPag_Rows:= ((FPagina + ARows) - 1);
    end;
  end;
end;
procedure TEntidadeBase<T>.Pagina(AValue: integer);
begin
  FPagina:= AValue;
end;
function TEntidadeBase<T>.Pagina: integer;
begin
  Result:= FPagina;
end;
procedure TEntidadeBase<T>.Pag_Rows(AValue: integer);
begin
  FPag_Rows:= AValue;
end;
function TEntidadeBase<T>.Pag_Rows: integer;
begin
  Result:= FPag_Rows;
end;
end.
