unit uCombustivel;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TCombustivel = class(TInterfacedObject, iEntidade)
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

{ TCombustivel }

constructor TCombustivel.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select P.COD_PROD, P.NOME_PROD, EF.QUANTIDADE ' +
                         'From PRODUTOS p ' +
                         'Left Join ESTOQUEFILIAL EF on (EF.COD_PROD = P.COD_PROD and EF.COD_FILIAL = :mCodFilial) ' +
                         'Where P.STATUS = ''A'' AND P.COD_MARCA = 1');

  InicializaDataSource;
end;

destructor TCombustivel.Destroy;
begin

  inherited;
end;

class function TCombustivel.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TCombustivel.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TCombustivel.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NOME_PROD');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TCombustivel.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From PRODUTOS Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TCombustivel.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.000';
end;

function TCombustivel.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
