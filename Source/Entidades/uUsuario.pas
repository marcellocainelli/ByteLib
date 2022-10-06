unit uUsuario;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TUsuario = class(TInterfacedObject, iEntidade)
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

{ TUsuario }

constructor TUsuario.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select U.*, U.COD_CAIXA as CODIGO, 0 as INDICE from USUARIO U Where (1 = 1)');
  InicializaDataSource;
end;

destructor TUsuario.Destroy;
begin
  inherited;
end;

class function TUsuario.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TUsuario.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TUsuario.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  If FEntidadeBase.RegraPesquisa = 'Contendo' then
      FEntidadeBase.RegraPesquisa('Containing')
  else If FEntidadeBase.RegraPesquisa = 'In�cio do texto' then
    FEntidadeBase.RegraPesquisa('Starting With');

  Case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + ' and U.COD_CAIXA = :mParametro';//busca por c�digo
  End;

  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and U.STATUS = ''A'' ';
  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TUsuario.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' and 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TUsuario.ModificaDisplayCampos;
begin

end;

function TUsuario.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
