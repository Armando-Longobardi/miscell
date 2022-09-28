function SendEmail(email)

% email = 'armando.longobardi@goodyear.com';
url = ['mailto:',email];
web(url)

end