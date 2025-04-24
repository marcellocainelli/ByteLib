unit uProducao_Etiquetas_Composicao;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, Dialogs;

Type
  TProducaoEtiquetasComposicao = class(TInterfacedObject, iEntidade)
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
      procedure SelecionaSQLConsulta;
  end;

implementation

uses
  uEntidadeBase;

{ TProducaoEtiquetasComposicao }

constructor TProducaoEtiquetasComposicao.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
end;

destructor TProducaoEtiquetasComposicao.Destroy;
begin
  inherited;
end;

class function TProducaoEtiquetasComposicao.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProducaoEtiquetasComposicao.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProducaoEtiquetasComposicao.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  ModificaDisplayCampos;
  Value.DataSet.Open;
  FEntidadeBase.SetReadOnly(Value, 'nome_prod', False);
  FEntidadeBase.SetReadOnly(Value, 'nome_fornec', False);
end;

function TProducaoEtiquetasComposicao.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.AddParametro('pCod_prod', -1);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProducaoEtiquetasComposicao.ModificaDisplayCampos;
begin

end;

function TProducaoEtiquetasComposicao.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TProducaoEtiquetasComposicao.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL(
    'select ppe.*, p.nome_prod, f.nome as nome_fornec ' +
    'from produtos_producao_etiquetas ppe ' +
    'join produtos p on (p.cod_prod = ppe.cod_prod) ' +
    'join fornec f on (f.codigo = ppe.cod_fornec) ' +
    'where ppe.cod_prod = :pCod_prod ');

end;

end.
