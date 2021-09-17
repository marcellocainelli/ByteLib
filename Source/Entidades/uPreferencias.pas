unit uPreferencias;

interface

uses
  uEntidadeBase,

  Data.DB,

  Model.Entidade.Interfaces,

  System.SysUtils;

Type
  TPreferencias = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;

      procedure ModificaDisplayCampos;
  end;

implementation

{ TPreferencias }

constructor TPreferencias.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from PREFERENCIAS WHERE ID = 1');
end;

destructor TPreferencias.Destroy;
begin
  inherited;
end;

class function TPreferencias.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TPreferencias.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TPreferencias.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TPreferencias.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TPreferencias.ModificaDisplayCampos;
begin

end;

end.
