[START form]
<form method="{method}" action="{url}">
{html}
</form>
[END form]
[START label]
  <div class="form-group">
    <label for="{id}">{label}</label>
    <div id="{id}">
        {inputHTML}
    </div>
  </div>
[END label]
[START password]
  <div class="form-group">
    <label for="{id}">{label}</label>
    <input type="password" class="form-control" id="{id}" name="{name}" placeholder="{placeholder}">
  </div>
[END password]
[START hidden]
    <input type="hidden" name="{name}" value="{value}">
[END hidden]
[START submit]
  <button type="submit" name="{name}" class="btn btn-purple">{label}</button>
[END submit]
[START text]
  <div class="form-group">
    <label for="{id}" class="{labelCSSClass}">{label}</label>
    <input type="text" class="form-control" id="{id}" value="{value}" name="{name}" placeholder="{placeholder}">
  </div>
[END text]
[START textarea]
  <div class="form-group">
    <label for="{id}">{label}</label>
    <textarea class="form-control" id="{id}" name="{name}" rows="{rows}"></textarea>
  </div>
[END textarea]
[START radio]
<div class="form-check">
  <input class="form-check-input" type="radio" name="{name}" id="{id}" value="{value}" {checked}>
  <label class="form-check-label" for="{id}">
    {label}
  </label>
</div>
[END radio]
[START checkbox]
  <div class="form-group form-check">
    <input type="checkbox" class="form-check-input" name="{name}" value="{value}" id="{id}">
    <label class="form-check-label" for="{id}">{label}</label>
  </div>
[END checkbox]
