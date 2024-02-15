unit uConfigImagens;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TAcessoMenu = class(TInterfacedObject, iEntidade)
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

{ TAcessoMenu }

constructor TAcessoMenu.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from CONFIG_IMAGENS WHERE ID = 1');
  InicializaDataSource;
end;

destructor TAcessoMenu.Destroy;
begin
  inherited;
end;

class function TAcessoMenu.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TAcessoMenu.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TAcessoMenu.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TAcessoMenu.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TAcessoMenu.ModificaDisplayCampos;
begin

end;

function TAcessoMenu.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
