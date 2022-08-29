unit uPosto_Tanques;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;
Type
  TPosto_Tanques = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;
implementation
uses
  uEntidadeBase;

{ TPosto_Tanques }

constructor TPosto_Tanques.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'Select A.*, B.NOME_PROD ' +
    'From TANQUE A ' +
    'Left Join PRODUTOS B On (A.COD_PROD = B.COD_PROD) ' +
    'Where A.COD_FILIAL = :pCod_Filial ');
  InicializaDataSource;
end;

destructor TPosto_Tanques.Destroy;
begin
  inherited;
end;

class function TPosto_Tanques.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPosto_Tanques.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPosto_Tanques.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NOME_PROD');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPosto_Tanques.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:=
    'Select A.*, B.NOME_PROD ' +
    'From TANQUE A ' +
    'Left Join PRODUTOS B On (A.COD_PROD = B.COD_PROD) ' +
    'Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPosto_Tanques.ModificaDisplayCampos;
begin

end;

function TPosto_Tanques.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
