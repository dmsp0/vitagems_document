package servletpackage;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import login.LoginDAO;
import login.LoginDTO;




@WebServlet("/loginComplete")
public class LoginController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
   
    public LoginController() {
        super();
    }
    
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		 String id = request.getParameter("id");
	     String password = request.getParameter("pw");
	     
	     boolean isValidUser = validateUser(id, password);
	     
	     if (isValidUser) {
	    	 HttpSession session = request.getSession(); 
	    	 session.setAttribute("user", id);
	    	 System.out.println("세션에 user라는 이름으로 입력한 id저장");
	    	 request.setAttribute("id", id);
	    	 System.out.println("request에 user라는 이름으로 입력한 id저장");
	    	// 위의 두 줄이 세션 생성 및 사용자 정보 저장
	            RequestDispatcher dispatcher = request.getRequestDispatcher("welcomeView.jsp");
	            dispatcher.forward(request, response);
	        } else {
	        	System.out.println("아이디혹은 비밀번호가 틀립니다.");
	        	response.sendRedirect("index.jsp");
	        }
	        
	}
	
	private boolean validateUser(String id, String password) {
		// 여기에 사용자 검증 로직 구현하기
		LoginDAO loginDao = new LoginDAO();
		LoginDTO loginDto = new LoginDTO();
		loginDto.setEmployeeCode(id);
		loginDto.setEmployeePassword(password);
		
		return loginDao.doLogin(loginDto);
	}

}
