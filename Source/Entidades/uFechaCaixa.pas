unit uFechaCaixa;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TFechaCaixa = class(TInterfacedObject, iEntidade)
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

{ TFechaCaixa }

constructor TFechaCaixa.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from FECHACAIXA');
  InicializaDataSource;
end;

destructor TFechaCaixa.Destroy;
begin
  inherited;
end;

class function TFechaCaixa.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TFechaCaixa.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TFechaCaixa.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  Case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + ' Where DATA = :DATA AND COD_FILIAL = :pCOD_FILIAL';
    2: vTextoSQL:= vTextoSQL + ' Where COD_CAIXA = :COD_CAIXA and DATA = :DATA and BAIXADO = :BAIXADO AND COD_FILIAL = :pCOD_FILIAL';
  end;
  FEntidadeBase.Iquery.IndexFieldNames('DATA');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TFechaCaixa.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From FECHACAIXA Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TFechaCaixa.ModificaDisplayCampos;
begin

end;

function TFechaCaixa.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
