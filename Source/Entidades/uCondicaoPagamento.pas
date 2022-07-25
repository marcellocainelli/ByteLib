unit uCondicaoPagamento;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TCondicaoPagamento = class(TInterfacedObject, iEntidade)
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

{ TCondicaoPagamento }

constructor TCondicaoPagamento.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('');
  InicializaDataSource;
end;

destructor TCondicaoPagamento.Destroy;
begin
  inherited;
end;

class function TCondicaoPagamento.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TCondicaoPagamento.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TCondicaoPagamento.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= 'Select DATAPAGTO as CODIGO, DESCRICAO as NOME, TIPO, CONDICAO1, CONDICAO2, CONDICAO3 From CONDPGTO';
    1: vTextoSQL:= 'select * from CONDPGTO';
  End;
  vTextoSQL:= vTextoSQL + ' Order By 2';
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TCondicaoPagamento.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * From CONDPGTO Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TCondicaoPagamento.ModificaDisplayCampos;
begin

end;

function TCondicaoPagamento.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
