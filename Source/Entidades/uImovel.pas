unit uImovel;

interface

uses
  Model.Entidade.Interfaces, Data.DB;
Type
  TImovel = class(TInterfacedObject, iEntidade)
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

{ TImovel }

constructor TImovel.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From IMOVEL Where COD_CLI = :pCod_Cli');
  InicializaDataSource;
end;

destructor TImovel.Destroy;
begin
  inherited;
end;

class function TImovel.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TImovel.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TImovel.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TImovel.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From IMOVEL Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TImovel.ModificaDisplayCampos;
begin
  TStringField(FEntidadeBase.Iquery.Dataset.FieldByName('CNPJ')).EditMask:= '##.###.###/####-##;1;_';
  TStringField(FEntidadeBase.Iquery.Dataset.FieldByName('cep')).EditMask:= '00000\-999;1;_';
end;

function TImovel.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
