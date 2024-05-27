unit uClienteCarro;

interface

uses
  Model.Entidade.Interfaces, Data.DB;
Type
  TClienteCarro = class(TInterfacedObject, iEntidade)
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


{ TClienteCarro }

constructor TClienteCarro.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from CARRO where COD_CLI = :pCod_Cli ');
  InicializaDataSource;
end;

destructor TClienteCarro.Destroy;
begin
  inherited;
end;

class function TClienteCarro.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TClienteCarro.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TClienteCarro.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  Case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + ' and PLACA = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NOME_CARRO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TClienteCarro.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From CARRO Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TClienteCarro.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('LIMITE')).DisplayFormat:= '#,0.00';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('DATA_TROCAOLEO')).EditMask:= '!99/99/00;1;_';
end;

function TClienteCarro.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
