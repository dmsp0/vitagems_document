package servletpackage;

import java.io.IOException;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import employee.EmployeeDAO;
import employee.EmployeeDTO;




@WebServlet("*.employeeDo")
public class EmployeeInfoController extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
   
    public EmployeeInfoController() {
        super();
    }
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	//#1. 사용자 요청이 들어오면 요청 경로(path)를 추출
    			final String URI = request.getRequestURI();
    			final String PATH =	URI.substring(URI.lastIndexOf("/"));
//    			
//    			//요청에 따라 처리하기
    			//#1.전체사원조회
    			if(PATH.equals("/employeeSearchView.employeeDo")) {
    				EmployeeDAO eDAO = new EmployeeDAO();
    				List<EmployeeDTO> eDTOList = eDAO.getAllEmployee();
    			
    			request.setAttribute("eDTOList", eDTOList);
    			RequestDispatcher dispatcher = request.getRequestDispatcher("employeeSearchView.jsp");
    		    dispatcher.forward(request, response); // employeeSearchView.jsp 페이지로 포워딩
    				
    			}else if(PATH.equals("/employeeSearchView.select")) { // 개별사원조회
    				System.out.println("라라");
    			}else {
    				System.out.println("이거뭔데");
    			}
    	
    }
	
//	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//		response.getWriter().append("Served at: ").append(request.getContextPath());
//	}
//
//	
//	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//		doGet(request, response);
//	}

}
