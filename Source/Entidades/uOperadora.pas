unit uOperadora;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TOperadora = class(TInterfacedObject, iEntidade)
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

{ TOperadora }

constructor TOperadora.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select O.*, null as INDICE from OPERADORA O where (1 = 1) ');

  InicializaDataSource;
end;

destructor TOperadora.Destroy;
begin
  inherited;
end;

class function TOperadora.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TOperadora.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TOperadora.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and O.STATUS = ''A'' ';
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(vTextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TOperadora.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' and 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TOperadora.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('DESCONTO')).DisplayFormat:= '#,0.00';
end;

function TOperadora.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
