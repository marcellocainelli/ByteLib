unit uAgenda;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TAgenda = class(TInterfacedObject, iEntidade)
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

{ TGrupo }

constructor TAgenda.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'Select a.* From AGENDA a ' +
    'Where ((a.cod_usuario = :pCod_Usuario) ' +
    'or (a.visualizacao = 1) ' +
    'or (a.visualizacao = 2 and a.agenda_grupos_codigo in ' +
    '(select agu.agenda_grupos_codigo from agenda_grupos_usuarios agu where agu.usuario_cod_caixa = :pCod_Usuario))) ');
  InicializaDataSource;
end;

destructor TAgenda.Destroy;
begin
  inherited;
end;

class function TAgenda.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TAgenda.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TAgenda.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= FEntidadeBase.TextoSQL;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSql:= vTextoSql + ' and a.DATA = :pData Order By a.HORA';
    1: vTextoSql:= vTextoSql + ' and Extract(Year From a.DATA) = :pAno and Extract(Month From a.DATA) = :pMes Order By a.DATA, a.HORA';
    2: vTextoSql:= vTextoSql + ' and Extract(Year From a.DATA) = :pAno Order By a.DATA, a.HORA';
  end;
  FEntidadeBase.AddParametro('pCod_Usuario', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.SQL(vTextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TAgenda.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL('Select * From AGENDA Where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TAgenda.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('data')).EditMask:= '!99/99/00;1;_';
  TTimeField(FEntidadeBase.Iquery.Dataset.FieldByName('hora')).EditMask:= '!99:99;1;_';
end;

function TAgenda.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
