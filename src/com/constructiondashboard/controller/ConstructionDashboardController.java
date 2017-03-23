package com.constructiondashboard.controller;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.TreeMap;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import com.constructiondashboard.delegate.LoginDelegate;
import com.constructiondashboard.model.Far;
import com.constructiondashboard.model.Project;
import com.constructiondashboard.service.PmService;
import com.constructiondashboard.service.ProjectService;
import com.constructiondashboard.service.VendorsPrimeService;
import com.constructiondashboard.service.VendorsSubService;
import com.constructiondashboard.viewBean.LoginBean;


@Controller
public class ConstructionDashboardController {
	
	@Autowired
	private LoginDelegate loginDelegate;
	
	@Autowired
	ProjectService projectService;

	@Autowired
	PmService pmService;
	
	@Autowired
	VendorsPrimeService vendorsPrimeService;
	
	@Autowired
	VendorsSubService vendorsSubService;
	
	@RequestMapping(value="/login",method=RequestMethod.GET)
	public ModelAndView displayLogin(HttpServletRequest request, HttpServletResponse response) {
		ModelAndView model = new ModelAndView("login");
		LoginBean loginBean = new LoginBean();
		model.addObject("loginBean", loginBean);
		return model;
	}
	
	@RequestMapping(value="/login",method=RequestMethod.POST)
	public ModelAndView executeLogin(HttpServletRequest request, HttpServletResponse response, @ModelAttribute("loginBean")LoginBean loginBean) {
		ModelAndView model = null;
		try {
			boolean isValidUser = loginDelegate.isValidUser(loginBean.getUsername(), loginBean.getPassword());
			if(isValidUser) {
				System.out.println("User Login Successful");
				request.setAttribute("loggedInUser", loginBean.getUsername());
				//model = new ModelAndView("league");
				model = new ModelAndView("dashboard");
				
				// String[] leagues = 
			}
			else {
				System.out.println("Not a valid user");
				model = new ModelAndView("login");
				model.addObject("loginBean", loginBean);
				request.setAttribute("message", "Invalid credentials!!");
			}

		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return model;
	}
	
	@RequestMapping("/welcome")
	public ModelAndView welcome(@RequestParam("username") String username) {
 
		String message;
		
		message = "<br><div style='text-align:center;'>"
				+ "<h3>********** Goodbye World, Spring MVC Tutorial</h3>This message is coming from CrunchifyHelloWorld.java **********</div><br><br>";
		return new ModelAndView("goodbye", "message", message + " " + username);
	
	}
	
	@RequestMapping("/getProjects")
	public @ResponseBody String getProjects(@RequestParam("username") String username) {
 
		JSONArray arrayJSON = projectService.getProjects(username);
		
    	return arrayJSON.toString();
	
	}
	
	@RequestMapping("/getPms")
	public ModelAndView getPMs(@RequestParam("username") String username, ModelMap model, @RequestParam("v1") String pmName) {
 
		System.out.println("getPMs");
		
    	String jsonArrayString = pmService.getPms(username).toString();
    	
    	model.addAttribute("pmJSONArray", jsonArrayString);
    	model.addAttribute("pmName", pmName);    	
    	
    	return new ModelAndView("tabPmDash");
	
	}
	
	@RequestMapping("/getPmDetail")
	public @ResponseBody String getPmDetail(@RequestParam("username") String username, int pmid) {
 
		System.out.println("In getPmDetail Java Controller");
		
    	String jsonArrayString = pmService.getPmDetail(username, pmid).toString();
    	
    	System.out.println("About to return from getPmDetail Controller. jsonArrayString: " + jsonArrayString);
    	
    	return jsonArrayString;
	
	}
	
	@RequestMapping(value="/getProject") 
	public ModelAndView getProject(@RequestParam("username") String username, @RequestParam("projectid") String projectid, HttpServletRequest request, ModelMap model) throws Exception {
	    System.out.println("getProject called.");
	    //ModelAndView mav = new ModelAndView();
	    request.setAttribute("loggedInUser", username);
	    
	    Project project = projectService.getProjectInfo(username, projectid);
	    
		//Map model=new HashMap();
	    
	    Random rand = new Random();

	    int  n = rand.nextInt(10000) + 1;
	    //50 is the maximum and the 1 is our minimum 
	    
		model.addAttribute("projectid", project.getProjectid());
		model.addAttribute("pmname", project.getPmname());
		model.addAttribute("projectidrnd", n);
		model.addAttribute("projectname", project.getProjectname());
		model.addAttribute("fundsource", project.getFundsource());
		model.addAttribute("projectphase", project.getProjectphase());
		model.addAttribute("location", project.getLocation());
		model.addAttribute("fars", project.getFars());
		model.addAttribute("etpc", project.getEtpc());
		model.addAttribute("projectstart", project.getProjectstart());
		model.addAttribute("beneficialocc", project.getBeneficialocc());
		model.addAttribute("address", project.getAddress());
		
		//List<Far> listFars = projectService.getProjectFarInfoJSON(username, projectid);
		
		//System.out.println("listFars: " + listFars.toString());
		
		JSONArray arrayJSON = projectService.getProjectFarInfoJSON(username, projectid);
		
		model.addAttribute("totalPendingFARs", arrayJSON.getJSONObject(arrayJSON.length()-1).get("totalPendingFARs"));
		// System.out.println("arrayJSON.getJSONObject: " + arrayJSON.getJSONObject(arrayJSON.length()-1));
		arrayJSON.remove(arrayJSON.length()-1);
		
		model.addAttribute("totalApprovedFARs", arrayJSON.getJSONObject(arrayJSON.length()-1).get("totalApprovedFARs"));
		arrayJSON.remove(arrayJSON.length()-1);
		
		model.addAttribute("farList", arrayJSON);
		
		//mav.addObject(model);
		
		System.out.println("model: " + model.toString());
		
	    return new ModelAndView("tabProject");
	}

	
	@RequestMapping("/getVendorsPrime")
	public ModelAndView getVendorsPrime(@RequestParam("username") String username, HttpServletRequest request, ModelMap model) throws Exception {

    	String jsonArrayString = vendorsPrimeService.getVendorsPrime(username).toString();
 
    	model.addAttribute("vendorsJSONArray", jsonArrayString);

    	return new ModelAndView("tabVendorsPrimeDash");
    	
		//return getProject(username, "P0000001", request, model);
		
	}
	
	@RequestMapping("/getVendorsSub")
	public ModelAndView getVendorsSub(@RequestParam("username") String username, HttpServletRequest request, ModelMap model) throws Exception {

    	String jsonArrayString = vendorsSubService.getVendorsSub(username).toString();
 
    	model.addAttribute("subcontractorsJSONArray", jsonArrayString);

    	return new ModelAndView("tabVendorsSubDash");
    	
		//return getProject(username, "P0000001", request, model);
		
	}
	
	@RequestMapping("/getVendorPrimeDetail")
	public @ResponseBody String getVendorPrimeDetail(@RequestParam("username") String username, @RequestParam("vendorid") String vendorid) throws Exception {

    	String jsonArrayString = vendorsPrimeService.getVendorPrimeDetail(username, vendorid).toString();
 
    	return jsonArrayString;
    	
		//return getProject(username, "P0000001", request, model);
		
	}
	
	@RequestMapping("/getVendorSubDetail")
	public @ResponseBody String getVendorSubDetail(@RequestParam("username") String username, @RequestParam("subcontractorid") String vendorid) throws Exception {

    	String jsonArrayString = vendorsSubService.getVendorSubDetail(username, vendorid).toString();
 
    	return jsonArrayString;
    	
		//return getProject(username, "P0000001", request, model);
		
	}
	
	@RequestMapping("/goodbye")
	public ModelAndView goodbye() {
 
		String message = "<br><div style='text-align:center;'>"
				+ "<h3>********** Goodbye World, Spring MVC Tutorial</h3>This message is coming from CrunchifyHelloWorld.java **********</div><br><br>";
		return new ModelAndView("goodbye", "message", message);
	}
	
	@RequestMapping("/faq")
	public ModelAndView faq() {
 
		String message = "<br><div style='text-align:center;'>"
				+ "<h3>********** Login World, Spring MVC Tutorial</h3>This message is coming from CrunchifyHelloWorld.java **********</div><br><br>";
		return new ModelAndView("faq", "message", message);
	}
	
}


