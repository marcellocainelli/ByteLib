unit uProfissional;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TProfissional = class(TInterfacedObject, iEntidade)
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

{ TItensPedido }

constructor TProfissional.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select P.*, 0 as INDICE From PROFISSIONAIS P ');

  InicializaDataSource;
end;

destructor TProfissional.Destroy;
begin
  inherited;
end;

class function TProfissional.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TProfissional.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TProfissional.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= '';
  {$IFDEF APP}
  if FEntidadeBase.RegraPesquisa = 'Contendo' then
    FEntidadeBase.RegraPesquisa('Containing')
  else if FEntidadeBase.RegraPesquisa = 'Início do texto' then
    FEntidadeBase.RegraPesquisa('LIKE');
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSql + 'Where CODIGO = :Parametro';
    1: vTextoSQL:= FEntidadeBase.TextoSql + 'Where Upper(NOME) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro) || ' + QuotedStr('%');
  end;
  {$ELSE}
  if FEntidadeBase.RegraPesquisa = 'Contendo' then
    FEntidadeBase.RegraPesquisa('Containing')
  else if FEntidadeBase.RegraPesquisa = 'Início do texto' then
    FEntidadeBase.RegraPesquisa('Starting With');
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSql + 'Where CODIGO = :Parametro';
    1: vTextoSQL:= FEntidadeBase.TextoSql + 'Where Upper(NOME) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
  end;
  {$ENDIF}
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TProfissional.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('Parametro', '-1', ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProfissional.ModificaDisplayCampos;
begin

end;

function TProfissional.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
