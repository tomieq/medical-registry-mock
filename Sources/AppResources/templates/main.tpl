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
  <header class="mb-1 text-purple">
    <div class="gray-shadow">

        <div class="col-12 pb-4">
        <img class="img-fluid app-logo"  src="assets/images/logo.png" />
          <span class="app-name">Rejestr hematologiczny</span>

        </div>
    </div>
  </header>




  
    {inline_notice_failure}
    {inline_notice_warning}
    {inline_notice_success}
    {inline_notice_info}

        {page}


  <!-- Footer -->
  <footer>
      COPYRIGHT © 2021 <a href="https://fundacja.hematologiczna.org/">Fundacja hematologiczna</a>, All rights Reserved
    </div>
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
