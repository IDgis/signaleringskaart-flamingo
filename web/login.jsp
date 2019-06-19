<%--
Copyright (C) 2012 B3Partners B.V.
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.
You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="/WEB-INF/jsp/taglibs.jsp"%>

<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="teststring" content="<title>Inloggen</title>">
    <title>Inloggen</title>
    <style>
      html {
        width: 100%;
        height: 100%;
        overflow: hidden;
      }
      @media screen and (max-width: 1375px) {
        body {
          margin: 0;
          background-image: url("../resources/images/ev_sk_splash.jpg");
          background-repeat: no-repeat;
          background-size: contain;
          width: 100%;
          height: 0;
          padding-top: 70.17%; /* (img-height / img-width * container-width) => (1343 / 1914 * 100) */
        }
        .panel-centered {
          position: absolute;
          width: 300px;
          height: 225px;
          left: 20px;
          top: 12vw;
          font-family: 'Open Sans', 'Helvetica Neue', helvetica, arial, verdana, sans-serif;
        }
      }
      @media screen and (min-width: 1375px) {
        body {
          margin: 0;
          background-image: url("../resources/images/ev_sk_splash.jpg");
          background-repeat: no-repeat;
          background-size: contain;
          background-position-x: center;
          width: 100%;
          height: 100%;
        }
        .panel-centered {
          position: absolute;
          width: 300px;
          height: 225px;
          left: calc((100vw - 1335px) / 2);
          top: 164px;
          font-family: 'Open Sans', 'Helvetica Neue', helvetica, arial, verdana, sans-serif;
        }
      }
      .panel-default {
        border-color: #eaeff0;
      }
      .panel {
        background-color: #fff;
        border: 1px solid transparent;
        border-color: #eaeff0;
        border-radius: 4px;
        box-shadow: 0 1px 1px rgba(0,0,0,.05);
      }
      .panel-default > .panel-heading {
        color: #fff;
        background-color: #ff9500;
        border-color: #ddd;
      }
      .panel-heading {
        padding: 10px 15px;
        border-bottom: 1px solid transparent;
        border-top-left-radius: 3px;
        border-top-right-radius: 3px;
      }
      .panel-title {
        margin-top: 0;
        margin-bottom: 0;
        font-size: 16px;
        color: inherit;
      }
      h3 {
        font-family: inherit;
        font-weight: 500;
        line-height: 1.1;
      }
      .panel-body {
        padding: 15px;
      }
      fieldset {
        min-width: 0;
        padding: 0;
        margin: 0;
        border: 0;
      }
      .form-group {
        margin-bottom: 15px;
      }
      .form-control {
        display: block;
        width: 100%;
        height: 34px;
        padding: 6px 12px;
        font-size: 14px;
        line-height: 1.42857143;
        color: #555;
        background-color: #fff;
        background-image: none;
        border: 1px solid #ccc;
        border-radius: 4px;
        -webkit-box-shadow: inset 0 1px 1px rgba(0,0,0,.075);
        box-shadow: inset 0 1px 1px rgba(0,0,0,.075);
        -webkit-transition: border-color ease-in-out .15s,-webkit-box-shadow ease-in-out .15s;
        -o-transition: border-color ease-in-out .15s,box-shadow ease-in-out .15s;
        transition: border-color ease-in-out .15s,box-shadow ease-in-out .15s;
      }
      .btn-block {
        display: block;
        width: 100%;
      }
      .btn-lg {
        padding: 10px 16px;
        font-size: 18px;
        line-height: 1.33;
        border-radius: 6px;
      }
      .btn-success {
        color: #fff;
        background-color: #5cb85c;
        border-color: #4cae4c;
      }
      .btn{
        margin-bottom: 0;
        font-weight: 400;
        text-align: center;
        white-space: nowrap;
        vertical-align: middle;
        cursor: pointer;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
        background-image: none;
        border: 1px solid transparent;
      }
      * {
        box-sizing: border-box;
      }
    </style>
  </head>
  <body>
    <div class="panel panel-default panel-centered">
      <div class="panel-heading">
        <h2 class="panel-title">Inloggen</h2>
      </div>
      <div class="panel-body">
        <form method="post" action="j_security_check">
          <fieldset>
            <div class="form-group">
              <input type="email" name="j_username" class="form-control loginfield" autofocus placeholder="Email" />
            </div>
            <div class="form-group">
              <input type="password" name="j_password" class="form-control loginfield" placeholder="Wachtwoord" />
            </div>
            <button class="btn btn-lg btn-success btn-block" type="submit" name="submit">Login</button>
          </fieldset>
        </form>
      </div>
    </div>
  </body>
</html>
