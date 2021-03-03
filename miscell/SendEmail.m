function SendEmail(email)

% email = 'armando.longobardi@pirelli.com';
url = ['mailto:',email];
web(url)

end