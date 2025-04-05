unit uEstFilialGradeEntrada;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TEstFilialGradeEntrada = class(TInterfacedObject, iEntidade)
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

{ TEstFilialGradeEntrada }

constructor TEstFilialGradeEntrada.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select efge.*, efg.cod_tamanho, efg.cod_cor, pt.descricao as descrtamanho, pc.descricao as descrcor ' +
    'from estfilial_grade_entrada efge ' +
    'join estoquefilial_grade efg on (efg.id = efge.id_estoquefilial_grade) ' +
    'left join produtos_tamanho pt on (pt.codigo = efg.cod_tamanho) ' +
    'left join produtos_cores pc on (pc.codigo = efg.cod_cor) ');
  InicializaDataSource;
end;

destructor TEstFilialGradeEntrada.Destroy;
begin
  inherited;
end;

class function TEstFilialGradeEntrada.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TEstFilialGradeEntrada.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TEstFilialGradeEntrada.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSql: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL + 'where seq_estoque = :pseqestoque ';
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.SetReadOnly(Value, 'cod_tamanho', False);
  FEntidadeBase.SetReadOnly(Value, 'cod_cor', False);
  FEntidadeBase.SetReadOnly(Value, 'descrtamanho', False);
  FEntidadeBase.SetReadOnly(Value, 'descrcor', False);
end;

function TEstFilialGradeEntrada.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= FEntidadeBase.TextoSQL + 'Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TEstFilialGradeEntrada.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TEstFilialGradeEntrada.ModificaDisplayCampos;
begin

end;

end.
