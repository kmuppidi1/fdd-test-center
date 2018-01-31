package com.fangdd.testcenter.web.filter;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.Collection;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.NoSuchElementException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ReadListener;
import javax.servlet.ServletException;
import javax.servlet.ServletInputStream;
import javax.servlet.ServletOutputStream;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.WriteListener;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.output.TeeOutputStream;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.alibaba.fastjson.JSON;

/**
 * 打印和记录请求处理耗时.
 *
 * @since 1.0.0
 */
public class LoggerAndProfilerFilter implements Filter {
	private static final Logger logger = LoggerFactory.getLogger(LoggerAndProfilerFilter.class);

	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
		logger.info("初始化LoggerAndProfilerFilter系统日志模块");
	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {
		try {
			HttpServletRequest httpServletRequest = (HttpServletRequest) request;
			HttpServletResponse httpServletResponse = (HttpServletResponse) response;

			String requestUri = httpServletRequest.getRequestURI();

			long startTime = System.currentTimeMillis();
			Map<String, String> requestMap = this.getTypesafeRequestMap(httpServletRequest);
			BufferedRequestWrapper bufferedRequest = new BufferedRequestWrapper(httpServletRequest);
			BufferedResponseWrapper bufferedResponse = new BufferedResponseWrapper(httpServletResponse);

			String threadName = System.nanoTime() + "";
			Thread.currentThread().setName(threadName);
			String requestBody = "";

			// 如果是multi-part，则不打印requestbody.
			String contentType = httpServletRequest.getContentType();
			if (contentType != null && (contentType.indexOf("plain") != -1 || contentType.indexOf("json") != -1
					|| contentType.indexOf("xml") != -1)) {
				requestBody = bufferedRequest.getRequestBody();
			}

			String headerToString = extractHeaderToString(httpServletRequest);

			logger.info(
					"Request URI: {}, HttpMethod: {}, RequestHeader: {}, ContentType: {}, RequestParam: {}, RequestBody: {}",
					requestUri, httpServletRequest.getMethod(), headerToString, contentType, requestMap, requestBody);

			chain.doFilter(bufferedRequest, bufferedResponse);

			long endTime = System.currentTimeMillis();

			logger.info("Request URI: {}, ResponseStatus={}, Response={}", requestUri, httpServletResponse.getStatus(),
					bufferedResponse.getContent());
			logger.info("Request URI: {}, elapsed time: {}ms", requestUri, (endTime - startTime));

		} catch (Exception e) {
			logger.error("loggerAndProfilerFilter exception: ", e);
		}
	}

	/**
	 * 处理header.
	 * userId/token/businessType/deviceToken/platform/cityId/channel/version/
	 * platformVersion
	 *
	 * @param request
	 * @return
	 */
	private String extractHeaderToString(HttpServletRequest request) {
		Enumeration<String> headerNames = request.getHeaderNames();
		if (headerNames == null) {
			return "";
		}
		Map<String, Object> headerMap = new HashMap<String, Object>();
		while (headerNames.hasMoreElements()) {
			String header = headerNames.nextElement();

			headerMap.put(header, request.getHeader(header));
		}
		return JSON.toJSONString(headerMap);
	}

	private Map<String, String> getTypesafeRequestMap(HttpServletRequest request) {
		Map<String, String> typesafeRequestMap = new HashMap<String, String>();
		Enumeration<?> requestParamNames = request.getParameterNames();
		while (requestParamNames.hasMoreElements()) {
			String requestParamName = (String) requestParamNames.nextElement();
			String requestParamValue = request.getParameter(requestParamName);
			typesafeRequestMap.put(requestParamName, requestParamValue);
		}
		return typesafeRequestMap;
	}

	@Override
	public void destroy() {
	}

	private static final class BufferedRequestWrapper extends HttpServletRequestWrapper {
		private ByteArrayInputStream bais = null;
		private ByteArrayOutputStream baos = null;
		private BufferedServletInputStream bsis = null;
		private byte[] buffer = null;

		public BufferedRequestWrapper(HttpServletRequest req) throws IOException {
			super(req);
			// Read InputStream and store its content in a buffer.
			InputStream is = req.getInputStream();
			this.baos = new ByteArrayOutputStream();
			byte buf[] = new byte[1024];
			int letti;
			while ((letti = is.read(buf)) > 0) {
				this.baos.write(buf, 0, letti);
			}
			this.buffer = this.baos.toByteArray();
		}

		@Override
		public Enumeration<String> getHeaders(String name) {
			if (null != name && name.equals("Content-Type")) {
				return new Enumeration<String>() {
					private boolean hasGetted = false;

					@Override
					public String nextElement() {
						if (hasGetted) {
							throw new NoSuchElementException();
						} else {
							hasGetted = true;
							return "application/json;charset=utf-8";
						}
					}

					@Override
					public boolean hasMoreElements() {
						return !hasGetted;
					}
				};
			}
			return super.getHeaders(name);
		}

		@Override
		public String getContentType() {
			if (super.getContentType() != null && super.getContentType().contains("application/json")) {
				return "application/json";
			}
			return super.getContentType();
		}

		@Override
		public ServletInputStream getInputStream() {
			this.bais = new ByteArrayInputStream(this.buffer);
			this.bsis = new BufferedServletInputStream(this.bais);
			return this.bsis;
		}

		String getRequestBody() throws IOException {
			BufferedReader reader = new BufferedReader(new InputStreamReader(this.getInputStream()));
			String line = null;
			StringBuilder inputBuffer = new StringBuilder();
			do {
				line = reader.readLine();
				if (null != line) {
					inputBuffer.append(line.trim());
				}
			} while (line != null);
			reader.close();
			return inputBuffer.toString().trim();
		}

	}

	private static final class BufferedServletInputStream extends ServletInputStream {
		private ByteArrayInputStream bais;

		public BufferedServletInputStream(ByteArrayInputStream bais) {
			this.bais = bais;
		}

		@Override
		public int available() {
			return this.bais.available();
		}

		@Override
		public int read() {
			return this.bais.read();
		}

		@Override
		public int read(byte[] buf, int off, int len) {
			return this.bais.read(buf, off, len);
		}

		@Override
		public boolean isFinished() {
			return read() == -1;
		}

		@Override
		public boolean isReady() {
			return true;
		}

		@Override
		public void setReadListener(ReadListener readListener) {

		}
	}

	public class TeeServletOutputStream extends ServletOutputStream {
		private final TeeOutputStream targetStream;

		public TeeServletOutputStream(OutputStream one, OutputStream two) {
			targetStream = new TeeOutputStream(one, two);
		}

		@Override
		public void write(int arg0) throws IOException {
			this.targetStream.write(arg0);
		}

		public void flush() throws IOException {
			super.flush();
			this.targetStream.flush();
		}

		public void close() throws IOException {
			super.close();
			this.targetStream.close();
		}

		@Override
		public boolean isReady() {
			return true;
		}

		@Override
		public void setWriteListener(WriteListener writeListener) {

		}
	}

	public class BufferedResponseWrapper implements HttpServletResponse {
		HttpServletResponse original;
		TeeServletOutputStream tee;
		ByteArrayOutputStream bos;

		public BufferedResponseWrapper(HttpServletResponse response) {
			original = response;
		}

		public String getContent() {
			if (bos != null) {
				return bos.toString();
			}
			return "";
		}

		public PrintWriter getWriter() throws IOException {
			return original.getWriter();
		}

		public ServletOutputStream getOutputStream() throws IOException {
			if (tee == null) {
				bos = new ByteArrayOutputStream();
				tee = new TeeServletOutputStream(original.getOutputStream(), bos);
			}
			return tee;

		}

		@Override
		public String getCharacterEncoding() {
			return original.getCharacterEncoding();
		}

		@Override
		public String getContentType() {
			return original.getContentType();
		}

		@Override
		public void setCharacterEncoding(String charset) {
			original.setCharacterEncoding(charset);
		}

		@Override
		public void setContentLength(int len) {
			original.setContentLength(len);
		}

		@Override
		public void setContentLengthLong(long l) {
			original.setContentLengthLong(l);
		}

		@Override
		public void setContentType(String type) {
			original.setContentType(type);
		}

		@Override
		public void setBufferSize(int size) {
			original.setBufferSize(size);
		}

		@Override
		public int getBufferSize() {
			return original.getBufferSize();
		}

		@Override
		public void flushBuffer() throws IOException {
			tee.flush();
		}

		@Override
		public void resetBuffer() {
			original.resetBuffer();
		}

		@Override
		public boolean isCommitted() {
			return original.isCommitted();
		}

		@Override
		public void reset() {
			original.reset();
		}

		@Override
		public void setLocale(Locale loc) {
			original.setLocale(loc);
		}

		@Override
		public Locale getLocale() {
			return original.getLocale();
		}

		@Override
		public void addCookie(Cookie cookie) {
			original.addCookie(cookie);
		}

		@Override
		public boolean containsHeader(String name) {
			return original.containsHeader(name);
		}

		@Override
		public String encodeURL(String url) {
			return original.encodeURL(url);
		}

		@Override
		public String encodeRedirectURL(String url) {
			return original.encodeRedirectURL(url);
		}

		@SuppressWarnings("deprecation")
		@Override
		public String encodeUrl(String url) {
			return original.encodeUrl(url);
		}

		@SuppressWarnings("deprecation")
		@Override
		public String encodeRedirectUrl(String url) {
			return original.encodeRedirectUrl(url);
		}

		@Override
		public void sendError(int sc, String msg) throws IOException {
			original.sendError(sc, msg);
		}

		@Override
		public void sendError(int sc) throws IOException {
			original.sendError(sc);
		}

		@Override
		public void sendRedirect(String location) throws IOException {
			original.sendRedirect(location);
		}

		@Override
		public void setDateHeader(String name, long date) {
			original.setDateHeader(name, date);
		}

		@Override
		public void addDateHeader(String name, long date) {
			original.addDateHeader(name, date);
		}

		@Override
		public void setHeader(String name, String value) {
			original.setHeader(name, value);
		}

		@Override
		public void addHeader(String name, String value) {
			original.addHeader(name, value);
		}

		@Override
		public void setIntHeader(String name, int value) {
			original.setIntHeader(name, value);
		}

		@Override
		public void addIntHeader(String name, int value) {
			original.addIntHeader(name, value);
		}

		@Override
		public void setStatus(int sc) {
			original.setStatus(sc);
		}

		@SuppressWarnings("deprecation")
		@Override
		public void setStatus(int sc, String sm) {
			original.setStatus(sc, sm);
		}

		@Override
		public int getStatus() {
			return 0;
		}

		@Override
		public String getHeader(String name) {
			return null;
		}

		@Override
		public Collection<String> getHeaders(String name) {
			return null;
		}

		@Override
		public Collection<String> getHeaderNames() {
			return null;
		}
	}
}