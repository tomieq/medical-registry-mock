<!DOCTYPE html>
<html lang="pl">

<head>

  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  [START meta]
  <meta name="{name}" content="{value}" />[END meta]
  <title>{title}</title>

  <!-- Bootstrap core CSS -->
  <link href="assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

  <!-- Custom styles for this template -->
  <link href="assets/vendor/fontawesome/css/all.min.css" rel="stylesheet">
  <link href="assets/css/style.css?v=1.1" rel="stylesheet">
  [START css]
  <link href="{src}" rel="stylesheet">
  [END css]
  <style>
  [START csscode] {code}
  [END csscode]
  </style>

</head>

<body>
  <!-- Header -->
  <header class="bg-blue pb-5 mb-4 text-white">
    <div class="container h-100">

      <nav class="navbar navbar-expand-lg navbar-dark">
        <a class="navbar-brand" href="/">Home</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
          <ul class="navbar-nav">
            <li class="nav-item active">
              <a class="nav-link" href="/projectList">Perspektywa admina</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="/myProjects">Perspektywa lekarza</a>
            </li>
          </ul>
        </div>
      </nav>

      <div class="row h-100 align-items-center">

        <div class="col-12">
          <h1 class="display-4 text-white mt-5 mb-2 text-center">Rejestr Hematologiczny Mock</h1>

        </div>
      </div>
    </div>
  </header>




  <!-- Page Content -->
  <div class="container">
  
        {inline_notice_failure}
        {inline_notice_warning}
        {inline_notice_success}
        {inline_notice_info}

        {page}

  </div>
  <!-- /.container -->

  <!-- Footer -->
  <footer class="mt-5 py-5 bg-dark">
    <div class="container">
      <p class="m-0 text-center text-white">Wszelkie prawa zastrzeżone &copy; Rejestr Hematologiczny 2021</p>
      <p class="text-center font-weight-light text-muted">v1.0.0</p>
    </div>
    <!-- /.container -->
  </footer>

  <!-- Bootstrap core JavaScript -->
  <script src="assets/vendor/jquery/jquery.min.js"></script>
  <script src="assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
  <script src="assets/js/common.js"></script>
  [START js]
  <script src="{src}"></script>
  [END js]
  <script>
  <!-- Begin
  [START jscode]
  {code}
  [END jscode]
  //  End -->
  </script>
</body>

</html>
