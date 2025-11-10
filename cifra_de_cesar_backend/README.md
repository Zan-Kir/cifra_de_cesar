# Cifra de César - Backend 
Este backend fornece autenticação via JWT e endpoints para salvar hashes do app Flutter.

Instalação

1. Copie `.env.example` para `.env` e configure `MONGO_URI` e `JWT_SECRET`.
2. No diretório `backend` execute:

```powershell
npm install
npm run dev
```

Rotas principais

- POST /auth/register  { email, password } (opcional)
- POST /auth/login     { email, password } -> { token }
- POST /hash           { hash, passo } (protected) -> cria registro usado=false
- GET /hash?hash=...   -> procura registro pelo valor do hash
- POST /hash/:id/use   -> marca registro como usado=true (protected)
 - POST /hash/consume  { hash } (protected) -> atomically marca como usado e retorna registro
 - Users CRUD (protegido):
	 - GET /users/me -> retorna perfil do usuário autenticado
	 - GET /users/:id -> retorna perfil (apenas próprio usuário)
	 - PUT /users/:id -> atualiza email/senha (apenas próprio usuário)
	 - DELETE /users/:id -> remove conta (apenas próprio usuário)

Use o token JWT no header Authorization: Bearer <token>
 
Fluxos relevantes para o front-end

- Tela de Cadastro: chama `POST /auth/register` para criar usuário.
- Tela de Login: chama `POST /auth/login` e armazena o token retornado.
- Tela de Criptografar: após gerar o hash no app, chame `POST /hash` com body `{ hash, passo }` e Authorization header para salvar o hash (usado=false).
- Tela de Descriptografar: chame `POST /hash/consume` com `{ hash }` (Authorization required). Se o hash existir e não tiver sido usado, o endpoint marca `usado=true` e retorna o registro (incluindo `passo`) para permitir a descriptografia. Se já usado, retorna erro 400.
