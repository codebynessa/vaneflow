# VaneFlow — P2 Programação Mobile (Flutter + Firebase)

Aplicativo de gerenciamento de tarefas pessoais feito em Flutter.
Cada usuário se cadastra, faz login por e-mail e senha e gerencia as próprias tarefas, que ficam salvas na nuvem (Firebase Realtime Database).

## Funcionalidades

- Cadastro (nome, e-mail, senha), login e logout (Firebase Authentication)
- Sessão mantida ao fechar e abrir o app
- Tela inicial com o nome do usuário e a contagem de tarefas (cadastradas, pendentes, concluídas)
- Menu lateral (Drawer): Início, Minhas tarefas, Configurações, Sobre o aplicativo e Sair, com nome e e-mail do usuário
- Cadastro, consulta, edição e exclusão de tarefas (título, descrição, vencimento, prioridade, situação)
- Listagem com ListView, cores e ícones por prioridade, filtro Todas/Pendentes/Concluídas
- Dados em tempo real com listeners (`onValue`), vinculados ao usuário logado (`tarefas/{uid}`)
- Tema claro/escuro salvo com SharedPreferences e aplicado em todas as telas

## Tecnologias

Flutter, Dart, Firebase Authentication, Firebase Realtime Database, SharedPreferences.

## Estrutura do projeto

```
lib/
├── main.dart                      # inicialização, rotas, tema e AuthGate
├── firebase_options.dart          # gerado pelo flutterfire configure
├── models/       usuario.dart, tarefa.dart
├── screens/      login, cadastro_usuario, home, tarefas,
│                 cadastro_tarefa, detalhes_tarefa, configuracoes, sobre
├── services/     auth_service, firebase_service, preferences_service
├── widgets/      drawer_menu, prioridade_badge
├── themes/       app_theme.dart
└── utils/        helpers.dart
```

## Como o banco guarda os dados

```
usuarios/{uid}      -> nome, email
tarefas/{uid}/{id}  -> titulo, descricao, dataVencimento, prioridade, concluida
```

As regras (`database.rules.json`) só permitem ler e escrever em `usuarios/{uid}` e `tarefas/{uid}` quando o `uid` for o do usuário logado. Assim, cada usuário só vê e altera as próprias tarefas.

## Como configurar e executar

### 1. Pré-requisitos
- Flutter instalado (`flutter doctor` sem erros)
- Conta Google
- Node.js instalado (para o Firebase CLI)

### 2. Instalar as dependências
```
flutter pub get
```

### 3. Configurar o Firebase
1. Acesse https://console.firebase.google.com e clique em **Adicionar projeto**.
2. Em **Authentication > Método de login**, ative **E-mail/senha**.
3. Em **Realtime Database**, clique em **Criar banco de dados** (modo bloqueado).
4. Na aba **Regras** do Realtime Database, cole o conteúdo de `database.rules.json` e clique em **Publicar**.

Este código já contém arquivos de configuração Firebase para o projeto usado no desenvolvimento. Para conectar a outro projeto Firebase, execute os comandos abaixo na pasta do app e selecione as plataformas desejadas:

```
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```
O comando atualiza `lib/firebase_options.dart`. Para Android, também baixe o `google-services.json` do projeto Firebase e coloque-o em `android/app/`.

### 4. Executar
```
flutter run
```

## Problemas comuns

- **Erro de `minSdkVersion` no Android:** em `android/app/build.gradle` (ou `build.gradle.kts`) coloque `minSdk = 23`.
- **Tarefas não aparecem / erro de permissão:** confira se as regras do passo 4 foram publicadas e se o banco foi criado.
- **`firebase_options.dart` não encontrado:** rode `flutterfire configure` na pasta do projeto.

## Capturas de tela

Adicione as capturas da demonstração em `docs/capturas/`:

- Login e cadastro
- Tela inicial
- Drawer
- Lista de tarefas
- Cadastro/edição de tarefa
- Detalhes da tarefa
- Configurações (tema claro e escuro)
- Dados no Firebase Realtime Database

## Roteiro do vídeo de demonstração

1. Cadastro de um usuário
2. Login com e-mail e senha
3. Cadastro de pelo menos duas tarefas
4. Edição e exclusão de uma tarefa
5. Visualização das tarefas no ListView
6. Logout e login novamente
7. Troca para o tema escuro e reabertura do app
8. Dados no Firebase Realtime Database (console, aba Dados)
