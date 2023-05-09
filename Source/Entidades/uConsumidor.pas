unit uConsumidor;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, Byte.Lib;
Type
  TConsumidor = class(TInterfacedObject, iEntidade)
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

{ TConsumidor }

constructor TConsumidor.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From CONSUMIDOR Where (1=1) and ');
  InicializaDataSource;
end;

destructor TConsumidor.Destroy;
begin
  inherited;
end;

class function TConsumidor.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TConsumidor.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TConsumidor.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSql + ' CPFCNPJ = :Parametro';
    1: vTextoSQL:= FEntidadeBase.TextoSql + ' NOME containing :Parametro';
  end;
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TConsumidor.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.AddParametro('Parametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' cpfcnpj = :Parametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TConsumidor.ModificaDisplayCampos;
begin

end;

function TConsumidor.DtSrc: TDataSource;
begin

end;

end.
